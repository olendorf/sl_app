# frozen_string_literal: true

module Async
  # Handles AJAX requests for shop data
  class ServiceBoardRentalsController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart'], params['ids']).to_json
    end

    def service_board_rental_status_chart(_ids = nil)
      ServiceBoardData.service_board_status_barchart(current_user)
    end

    def service_board_status_timeline(_ids = nil)
      ServiceBoardData.service_board_status_timeline(current_user)
    end

    def service_board_status_ratio_timeline(_ids = nil)
      ServiceBoardData.service_board_status_ratio_timeline(current_user)
    end

    def region_revenue_bar_chart(_ids = nil)
      ServiceBoardData.region_revenue_bar_chart(current_user)
    end

    def rental_income_timeline(_ids = nil)
      ServiceBoardData.rental_income_timeline(current_user)
    end
  end
end
