# frozen_string_literal: true

module Rezzable
  # Formatting and other functions for traffic cops
  class TrafficCopDecorator < AbstractWebObjectDecorator
    delegate_all

    def pretty_power
      h.content_tag :span, class: power? ? 'status_tag on' : 'status_tag off' do
        power? ? 'On' : 'Off'
      end
    end

    def pretty_sensor_mode
      sensor_mode.split('_')[2..].join(' ').titleize
    end

    def pretty_security_mode
      security_mode.split('_')[2..].join(' ').titleize
    end

    def pretty_access_mode
      access_mode.split('_')[2..].join(' ').titleize
    end

    # Define presentation-specific methods here. Helpers are accessed through
    # `helpers` (aka `h`). You can override attributes, for example:
    #
    #   def created_at
    #     helpers.content_tag :span, class: 'time' do
    #       object.created_at.strftime("%a %m/%d/%y")
    #     end
    #   end
  end
end
