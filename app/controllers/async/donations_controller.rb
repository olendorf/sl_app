# frozen_string_literal: true

module Async
  # Modeless controller for handling AJAX requests for displaying
  # donations data.
  class DonationsController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart']).to_json
    end

    private

    def donation_histogram
      current_user.donations.collect(&:amount)
    end

    def donor_amount_histogram
      current_user.donations.group(:target_name).sum(:amount).collect { |_k, v| v }
    end

    def donor_scatter_plot
      amounts = current_user.donations.group(:target_name).sum(:amount).sort_by do |_key, value|
        -value
      end.to_h
      counts = current_user.donations.group(:target_name).count
      amounts.collect { |k, v| { key: k, x: counts[k], y: v } }
    end
  end
end
# ?channel_id=2&product_ids[]=6900&product_ids[]=6901
