# frozen_string_literal: true

class AsyncController < ApplicationController
  include Pundit

  after_action :verify_authorized
  
  def time_series_dates(start, stop, interval = 1.day)
    dates = []
    step_time = start

    while step_time <= stop
      dates << step_time.strftime('%F')
      step_time += interval
    end
    dates
  end

  # def pundit_user
  #   current_user
  # end
end
