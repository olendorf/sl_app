# frozen_string_literal: true

module Rezzable
  # Model for traffpic cops.
  class TrafficCop < ApplicationRecord
    
    acts_as :abstract_web_object
    
    attr_accessor :detection
    
    before_update :handle_detection, if: :detection?

    has_many :visits, class_name: 'Analyzable::Visit',
                      dependent: :destroy,
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
  
    
        # rubocop:disable Style/RedundantSelf
    def response_data
      {
        api_key: self.api_key,
        settings: {
          power: power,
          sensor_mode: sensor_mode,
          security_mode: security_mode,
          first_visit_message: first_visit_message,
          repeat_visit_message: repeat_visit_message
        },
        data: {
        }
      }
    end
    # rubocop:enable Style/RedundantSelf
    
    private 
    
      def detection?
        !detection.nil?
      end
      
      def handle_detection
        self.detection = self.detection.with_indifferent_access
        previous_visit = visits.where(avatar_key: detection[:avatar_key]).
                            order(start_time: :desc).limit(1).first
        add_detection(previous_visit) and return if previous_visit && previous_visit.active?
        add_visit 
      end
      
      def add_visit   
        visit = Analyzable::Visit.new(
          avatar_key: detection[:avatar_key],
          avatar_name: detection[:avatar_name]
          )
        visit.detections << Analyzable::Detection.new(position: detection[:position].to_json)
        visits << visit
      end 
      
      def add_detection(previous_visit)
        previous_visit.detections << Analyzable::Detection.new(
          position: self.detection[:position].to_json
        )
      end
    
  end
end
