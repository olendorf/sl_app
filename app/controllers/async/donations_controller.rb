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

      data = amounts.collect { |k, v| { key: k, x: counts[k], y: v } }
      puts data.to_json
      data
    end
  end
end
