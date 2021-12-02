# frozen_string_literal: true

module Rezzable
  class ShopRentalBox < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior
    include RentableBehavior

    after_create -> { add_state('for_rent') }
    before_update :handle_rent_payment, if: :rent_payment
    after_update :check_land_impact, if: :new_land_impact

    attr_accessor :rent_payment, :target_name, :target_key, :new_land_impact

    OBJECT_WEIGHT = 1

    # def add_for_rent_state
    #   self.states << Analyzable::RentalState.new(state: 'for_rent', user_id: self.user_id)
    # end

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
        category: 'rent',
        target_name: target_name,
        target_key: target_key
      )
      user.transactions << transaction
    end

    def check_land_impact
      return unless user
      return if user.servers.size.zero?

      self.current_land_impact = new_land_impact
      self.new_land_impact = nil
      save

      if current_land_impact > allowed_land_impact
        server_id = user.servers.sample.id
        MessageUserWorker.perform_async(
          server_id, renter_name, renter_key,
          I18n.t('rezzable.shop_rental_box.land_impact_exceeded',
                 region_name: region,
                 allowed_land_impact: allowed_land_impact,
                 current_land_impact: current_land_impact)
        ) unless Rails.env.development?
      end
    end

    def add_state(state)
      states.last.update(closed_at: Time.current) if states.size.positive?
      states << Analyzable::RentalState.new(state: state, user_id: user_id)
      update(current_state: state)
    end
  end
end
