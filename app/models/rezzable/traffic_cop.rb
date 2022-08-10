# frozen_string_literal: true

module Rezzable
  # Model for traffpic cops.
  class TrafficCop < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior

    attr_accessor :detections, :outgoing_response, :has_access

    before_update :handle_detections, if: :detections?

    has_many :visits, class_name: 'Analyzable::Visit',
                      dependent: :nullify,
                      foreign_key: :web_object_id
    # accepts_nested_attributes_for :visits, allow_destroy: true

    has_many :listable_avatars, as: :listable, dependent: :destroy
    accepts_nested_attributes_for :listable_avatars, allow_destroy: true

    OBJECT_WEIGHT = 25

    LISTS = %i[allowed banned].freeze

    LISTS.each do |list|
      define_method("add_to_#{list}_list") do |avatar_name, avatar_key|
        listable_avatars << ListableAvatar.new(
          avatar_name: avatar_name,
          avatar_key: avatar_key,
          list_name: list.to_s
        )
      end

      define_method("#{list}_list") do
        listable_avatars.where(list_name: list.to_sym)
      end
    end

    enum sensor_mode: {
      sensor_mode_region: 0,
      sensor_mode_parcel: 1,
      sensor_mode_owned_parcels: 2
    }

    enum security_mode: {
      security_mode_off: 0,
      security_mode_parcel: 1,
      security_mode_owned_parcels: 2
    }

    enum access_mode: {
      access_mode_banned: 0,
      access_mode_allowed: 1
    }

    # rubocop:disable Style/RedundantSelf
    def response_data
      {
        api_key: self.reload.api_key,
        settings: {
          power: power,
          sensor_mode: sensor_mode,
          security_mode: security_mode,
          first_visit_message: first_visit_message,
          repeat_visit_message: repeat_visit_message,
          access_mode: access_mode
        },
        response: outgoing_response,
        has_access: has_access
      }
    end
    # rubocop:enable Style/RedundantSelf

    def current_visitors
      visits.where('stop_time > ?', 1.minute.ago)
    end

    def visitors
      counts = visits.group(:avatar_key).count
      data = visits.group(:avatar_key, :avatar_name).sum(:duration).collect do |k, v|
        { avatar_name: k.last, avatar_key: k.first, time_spent: v, visits: counts[k.first] }
      end
      data.sort_by { |h| -h[:time_spent] }
    end

    private

    def detections?
      !detections.nil?
    end

    def handle_detections
      self.outgoing_response = {
                                  first_visit_message: [], 
                                  second_visit_message: [],
                                  banned: []
                               }
      detections.each do |detection|
        detection = detection.with_indifferent_access
        determine_access(detection)
        self.outgoing_response[:banned] << detection[:avatar_key] unless has_access

        previous_visit = visits.where(avatar_key: detection[:avatar_key])
                               .order(start_time: :desc).limit(1).first
        add_detection(previous_visit) and return if previous_visit&.active?

        send_inventory(previous_visit)
        add_visit(detection, previous_visit)
        determine_message(detection, previous_visit)
      end
      self.detections = nil
    end

    def determine_access(detection)
      self.has_access = true
      self.has_access = banned_list.where(avatar_key: detection[:avatar_key]).size.zero?
      if access_mode_allowed? && has_access
        self.has_access = allowed_list.where(avatar_key: detection[:avatar_key]).size.positive?
      end
      has_access
    end

    def add_visit(detection, previous_visit)
      visit = Analyzable::Visit.new(
        avatar_key: detection[:avatar_key],
        avatar_name: detection[:avatar_name],
        region: region
      )
      visit.detections << Analyzable::Detection.new(position: detection[:position].to_json)
      visits << visit
    end

    def add_detection(previous_visit)
      previous_visit.detections << Analyzable::Detection.new(
        position: detection[:position].to_json
      )
    end

    def determine_message(detection, previous_visit)
      if(previous_visit.nil?)
        self.outgoing_response[:first_visit_message] << detection[:avatar_key]
      elsif(previous_visit.stop_time < Time.now -
                                           Settings.default.traffic_cop
                                                   .return_message_delay.days)
        self.outgoing_response[:second_visit_message] << repeat_visit_message
                
      end
    end

    def send_inventory(previous_visit)
      return unless inventory_to_give

      if !previous_visit || previous_visit.stop_time < Time.now -
                                                       Settings.default.traffic_cop
                                                               .return_message_delay.days

        inventory = server.inventories.find_by_inventory_name(inventory_to_give)
        InventorySlRequest.give_inventory(inventory.id, detection[:avatar_key])
      end
    end
  end
end
