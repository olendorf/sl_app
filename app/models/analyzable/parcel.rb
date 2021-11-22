# frozen_string_literal: true

module Analyzable
  # Model for inworld parcels for rent.
  class Parcel < ApplicationRecord
    after_create :handle_parcel_opening

    before_update :handle_tier_payment, if: :tier_payment
    before_update :handle_parcel_owner_change, if: :owner_key_changed?
    before_update :set_parcel_for_sale, if: :parcel_box_key

    has_one :parcel_box, class_name: 'Rezzable::ParcelBox', inverse_of: :parcel
    belongs_to :user
    has_many :states, as: :rentable, dependent: :destroy,
                      after_add: :set_current_state, 
                      class_name: 'Analyzable::RentalState'

    has_many :transactions, class_name: 'Analyzable::Transaction', dependent: :nullify

    attr_accessor :tier_payment, :requesting_object, :parcel_box_key

    def self.open_parcels(user, region)
      user.parcels.includes(:parcel_box).where(owner_key: nil, region: region,
                                               rezzable_parcel_boxes: { parcel_id: nil })
    end

    def handle_parcel_opening
      if requesting_object
        self.parcel_box = requesting_object
        self.region = requesting_object.region
        self.position = requesting_object.position
        states << Analyzable::RentalState.new(state: 'for_sale',
                                              user_id: requesting_object.user.id)
      else
        states << Analyzable::RentalState.new(state: 'open', user_id: user.id)
      end
    end

    # rubocop:disable Naming/AccessorMethodName
    def set_parcel_for_sale
      self.requesting_object = user.parcel_boxes.where(object_key: parcel_box_key).first
      states.last.update(closed_at: Time.current)
      # puts self.states.last.inspect
      handle_parcel_opening
    end

    # rubocop:disable Metrics/AbcSize
    def handle_parcel_owner_change
      parcel_box&.destroy
      states.last.update(closed_at: Time.current)
      if owner_key.nil?
        states << Analyzable::RentalState.new(state: :open, user_id: user.id)
        self.expiration_date = nil
      else
        states << Analyzable::RentalState.new(state: :occupied, user_id: user.id)
        user.transactions << Analyzable::Transaction.create(
          amount: purchase_price,
          category: :land_sale,
          target_name: owner_name,
          target_key: owner_key,
          parcel_id: id
        )
        self.expiration_date = 1.week.from_now
      end
    end

    def set_current_state(state)
      self.current_state = state.state
    end
    # rubocop:enable Naming/AccessorMethodName

    def handle_tier_payment
      added_time = tier_payment.to_f / weekly_tier

      self.expiration_date = Time.current if expiration_date.nil?
      self.expiration_date = expiration_date + (1.week.to_i * added_time)
      user.transactions << Analyzable::Transaction.create(
        amount: tier_payment,
        target_key: owner_key,
        target_name: owner_name,
        source_key: requesting_object.object_key,
        source_name: requesting_object.object_name,
        source_type: 'tier_station',
        category: 'tier',
        transactable_id: requesting_object.id,
        transactable_type: 'Rezzable::TierStation',
        parcel_id: id,
        description: "Tier payment from #{owner_name}"
      )
    end
    # rubocop:enable Metrics/AbcSize
  end
end
