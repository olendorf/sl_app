# frozen_string_literal: true

module Analyzable
  # Handles visits detected by a traffic cop
  class Visit < ApplicationRecord
    belongs_to :traffic_cop, class_name: 'Rezzable::TrafficCop',
                             foreign_key: :web_object_id

    has_many :detections, class_name: 'Analyzable::Detection',
                          dependent: :destroy,
                          before_add: :adjust_times
    accepts_nested_attributes_for :detections, allow_destroy: true

    def active?
      stop_time >= Time.now - (2 * Settings.default.traffic_cop.sensor_time)
    end

    private

    def adjust_times(_detection)
      self.start_time ||= Time.now
      self.stop_time = Time.now + (Settings.default.traffic_cop.sensor_time / 2.0).round
      self.duration = stop_time - start_time
      save
    end
  end
end
