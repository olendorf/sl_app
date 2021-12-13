# frozen_string_literal: true

module Rezzable
  # Models inworld service boards that allow avatars to advertise
  # services on a weekly fee basis.
  class ServiceBoard < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior
    include RentableBehavior

    after_create -> { add_state('for_rent') }
    before_update :handle_rent_payment, if: :rent_payment

    attr_accessor :rent_payment, :target_name, :target_key

    OBJECT_WEIGHT = 1

    # rubocop:disable Metrics/AbcSize
    def handle_rent_payment
      amount = rent_payment
      self.rent_payment = nil
      add_state('occupied') if states.last.state == 'for_rent'
      update(expiration_date: Time.current) if expiration_date.nil?
      update(
        expiration_date: expiration_date +
                         (amount.to_f / weekly_rent).weeks,
        renter_name: target_name,
        renter_key: target_key
      )
      transaction = Analyzable::Transaction.new(
        amount: amount,
        category: 'shop_rent',
        target_name: target_name,
        target_key: target_key
      )
      user.transactions << transaction
    end
    # rubocop:enable Metrics/AbcSize
  end
end
