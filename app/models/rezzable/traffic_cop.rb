# frozen_string_literal: true

module Rezzable
  # Model for traffpic cops.
  class TrafficCop < ApplicationRecord
    
    acts_as :abstract_web_object
    
    attr_accessor :detection
    attr_accessor :outgoing_response
    attr_accessor :has_access
    
    before_update :handle_detection, if: :detection?

    has_many :visits, class_name: 'Analyzable::Visit',
                      dependent: :nullify,
                      foreign_key: :web_object_id
    # accepts_nested_attributes_for :visits, allow_destroy: true

    has_many :listable_avatars, as: :listable, dependent: :destroy
    accepts_nested_attributes_for :listable_avatars, allow_destroy: true

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
        api_key: self.api_key,
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
    
    private 
    
      def detection?
        !detection.nil?
      end
      

      
      def handle_detection
        self.detection = self.detection.with_indifferent_access
        determine_access
        return unless has_access
        previous_visit = visits.where(avatar_key: detection[:avatar_key]).
                            order(start_time: :desc).limit(1).first
        add_detection(previous_visit) and return if previous_visit && previous_visit.active?
        add_visit (previous_visit)
        set_message(previous_visit)
      end
      
      def determine_access
        self.has_access = true
        self.has_access = self.banned_list.where(avatar_key: detection[:avatar_key]).size.zero?
        if access_mode_allowed? && self.has_access
          self.has_access = self.allowed_list.where(avatar_key: detection[:avatar_key]).size > 0
        end
        self.has_access
      end
      
      def add_visit(previous_visit)
        self.outgoing_response = previous_visit.nil? ? first_visit_message : repeat_visit_message
        visit = Analyzable::Visit.new(
          avatar_key: detection[:avatar_key],
          avatar_name: detection[:avatar_name],
          region: self.region
          )
        visit.detections << Analyzable::Detection.new(position: detection[:position].to_json)
        self.detection = nil
        visits << visit
      end 
      
      def add_detection(previous_visit)
        previous_visit.detections << Analyzable::Detection.new(
          position: self.detection[:position].to_json
        )
      end
      
      def set_message(previous_visit)
        self.outgoing_response = nil
        self.outgoing_response = first_visit_message and return unless previous_visit
        self.outgoing_response = repeat_visit_message if previous_visit.stop_time < Time.now - 
                                                             Settings.default.traffic_cop.return_message_delay.days
      end
    
  end
end
