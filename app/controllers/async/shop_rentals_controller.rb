# frozen_string_literal: true

module Async
  # Handles AJAX requests for shop data
  class ShopRentalsController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart'], params['ids']).to_json
    end

    def shop_rental_status_chart(_ids = nil)
      ShopData.shop_status_barchart(current_user)
    end

    def shop_status_timeline(_ids = nil)
      ShopData.shop_status_timeline(current_user)
    end

    def shop_status_ratio_timeline(_ids = nil)
      ShopData.shop_status_ratio_timeline(current_user)
    end

    def region_revenue_bar_chart(_ids = nil)
      ShopData.region_revenue_bar_chart(current_user)
    end

    def rental_income_timeline(_ids = nil)
      ShopData.rental_income_timeline(current_user)
    end
  end
end
