# frozen_string_literal: true

module Rezzable
  # Model for in world donatoin boxes taht take donations and collect
  # the data.
  class DonationBox < ApplicationRecord
    acts_as :abstract_web_object

    def last_donation
      transactions.to_ary.max_by(&:created_at)
    end

    def total_donations
      transactions.sum(:amount)
    end

    def largest_donation
      transactions.to_ary.sort_by(&:created_at).reverse.max_by(&:amount)
    end

    def biggest_donor
      data = transactions.group(:target_key, :target_name).sum(:amount).max_by { |_k, v| v }
      { avatar_key: data.first.first, avatar_name: data.first.second, amount: data.last }
    end
  end
end
