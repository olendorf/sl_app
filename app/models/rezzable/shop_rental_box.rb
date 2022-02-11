# frozen_string_literal: true

module Rezzable
  # Models in world shop rental boxes that allow users
  # to run shop rental business
  class ShopRentalBox < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior
    include RentableBehavior
    include TransactableBehavior

    after_create -> { add_state('for_rent') }
    before_update :handle_rent_payment, if: :rent_payment
    after_update :check_land_impact, if: :new_land_impact

    attr_accessor :rent_payment, :target_name, :target_key, :new_land_impact

    scope :for_rent, -> { where(current_state: :for_rent) }

    OBJECT_WEIGHT = 1

    # def add_for_rent_state
    #   self.states << Analyzable::RentalState.new(state: 'for_rent', user_id: self.user_id)
    # end

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
        target_key: target_key,
        transactable_id: id,
        transactable_type: self.class.name
      )
      transactions << transaction
    end
    # rubocop:enable Metrics/AbcSize

    def check_land_impact
      return unless user
      return if user.servers.size.zero?

      self.current_land_impact = new_land_impact
      self.new_land_impact = nil
      save

      return if current_land_impact <= allowed_land_impact

      server_id = user.servers.sample.id
      MessageUserWorker.perform_async(
        server_id, renter_name, renter_key,
        I18n.t('rezzable.shop_rental_box.land_impact_exceeded',
               region_name: region,
               allowed_land_impact: allowed_land_impact,
               current_land_impact: current_land_impact)
      ) unless Rails.env.development?
    end

    def transaction_category
      'shop_rent'
    end

    def transaction_description(transaction)
      "Shop rent from #{transaction.target_name} for #{object_name}"
    end

    # def self.process_rentals
    # end
  end
end
