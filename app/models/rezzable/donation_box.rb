# frozen_string_literal: true

module Rezzable
  # Model for in world donatoin boxes taht take donations and collect
  # the data.
  class DonationBox < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior
    include TransactableBehavior

    OBJECT_WEIGHT = 1

    def last_donation
      transaction = transactions.to_ary.max_by(&:created_at)
      transaction ||= Analyzable::Transaction.new
      transaction.attributes.slice('amount', 'target_key', 'target_name', 'created_at')
    end

    def total_donations
      transactions.collect(&:amount).sum
    end

    def largest_donation
      transaction = transactions.to_ary.sort_by(&:created_at).reverse.max_by(&:amount)
      transaction ||= Analyzable::Transaction.new
      transaction.attributes.slice('amount', 'target_key', 'target_name', 'created_at')
    end

    def biggest_donor
      return { avatar_key: nil, avatar_name: nil, amount: nil } if transactions.size.zero?

      data = transactions.group(:target_key, :target_name).sum(:amount).max_by { |_k, v| v }
      { avatar_key: data.first.first, avatar_name: data.first.second, amount: data.last }
    end

    # rubocop:disable Style/RedundantSelf
    def response_data
      {
        api_key: self.api_key,
        settings: {
          show_last_donation: show_last_donation,
          show_last_donor: show_last_donor,
          show_total: show_total,
          show_largest_donation: show_largest_donation,
          show_biggest_donor: show_biggest_donor,
          goal: goal,
          dead_line: dead_line
        },
        data: {
          last_donation: last_donation,
          total_donations: total_donations,
          largest_donation: largest_donation,
          biggest_donor: biggest_donor
        }
      }
    end
    # rubocop:enable Style/RedundantSelf

    def transaction_category
      'donation'
    end

    def transaction_description(transaction)
      "Donation from #{transaction.target_name}."
    end
  end
end
