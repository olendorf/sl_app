# frozen_string_literal: true

# Parent class for controllers handling asynchronous requests.
class AsyncController < ApplicationController
  include Pundit

  after_action :verify_authorized

  def time_series_dates(start, stop, interval = 1.day)
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
  def time_series_months(start, stop, interval = 1.month)
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

  def generate_color_map(items)
    md5 = Digest::MD5.new
    color_map = {}
    items.each do |i|
      color_map[i] = "##{md5.hexdigest(i)[0..5]}"
    end
    color_map
  end

  # def pundit_user
  #   current_user
  # end
end
