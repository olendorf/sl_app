# frozen_string_literal: true

# Helpers for creating requests into SL objects
module DataHelper
  extend ActiveSupport::Concern

  included do
    def self.stop_light_color_map
      {
        'open' => '#FF0D0D', 'for_sale' => '#FAB733', 'occupied' => '#ACB334', 'for_rent' => '#FAB733'
      }
    end
    
  def self.generate_color_map(items)
    md5 = Digest::MD5.new
    color_map = {}
    items.each do |i|
      color_map[i] = "##{md5.hexdigest(i)[0..5]}"
    end
    color_map
  end
  
  def self.time_series_dates(start, stop, interval = 1.day)
    dates = []
    step_time = start
    stop = Time.current if stop.nil?

    while step_time <= stop
      dates << step_time.strftime('%F')
      step_time += interval
    end
    dates
  end
  
  # rubocop:disable Style/ParenthesesAroundCondition
  def self.time_series_months(start, stop, interval = 1.month)
    dates = []
    step_time = start
    stop = Time.current if stop.nil?

    while (step_time <= stop)
      dates << step_time.strftime('%B %Y')
      step_time += interval
    end
    dates
  end
  # rubocop:enable Style/ParenthesesAroundCondition

  end
end
