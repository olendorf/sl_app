# frozen_string_literal: true

require 'benchmark'

module Async
  # Handles AJAX requests for data to create charts and tables.
  class RentalsController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart']).to_json
    end

    def parcel_status_treemap
      ParcelData.parcel_status_treemap(current_user)
    end

    def region_revenue_bar_chart
      ParcelData.region_revenue_bar_chart(current_user)
    end

    def parcel_status_timeline
      ParcelData.parcel_status_timeline(current_user)
    end

    def parcel_status_ratio_timeline
      ParcelData.parcel_status_ratio_timeline(current_user)
    end

    def rental_income_timeline
      ParcelData.rental_income_timeline(current_user)
    end
  end
end
