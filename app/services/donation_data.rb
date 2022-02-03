# frozen_string_literal: true

# Handles data processing for parcels
class DonationData
  include DataHelper

  def self.donor_scatter_plot(current_user)
    amounts = current_user.donations.group(:target_name).sum(:amount).sort_by do |_key, value|
      -value
    end.to_h
    counts = current_user.donations.group(:target_name).count
    # amounts.collect { |k, v| { x: counts[k], y: v } }
    amounts.collect { |k, v| [counts[k], v, k] }
  end
end
