# frozen_string_literal: true

module Analyzable
  # Decorotor with helper functions for parcels.
  class ParcelDecorator < Draper::Decorator
    delegate_all

    def slurl
      position = JSON.parse(self.position)
      "https://maps.secondlife.com/secondlife/#{region}/#{position['x'].round}/" \
        "#{position['y'].round}/#{position['z'].round}/"
      # text = "#{region} (#{position['x'].round}, " \
      #       "#{position['y'].round}, #{position['z'].round})"
    end

    def image_url(size)
      return "http://secondlife.com/app/image/#{image_key}/#{size}" if image_key
      if user.default_image_key
        return "http://secondlife.com/app/image/#{user.default_image_key}/#{size}"
      end

      'no_image_available.jpg'
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
