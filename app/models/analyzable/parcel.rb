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
    has_many :states, class_name: 'Analyzable::ParcelState', dependent: :destroy

    attr_accessor :tier_payment, :requesting_object, :parcel_box_key

    def self.open_parcels(user, region)
      user.parcels.includes(:parcel_box).where(owner_key: nil, region: region,
                                               rezzable_parcel_boxes: { parcel_id: nil })
    end

    def handle_parcel_opening
      self.parcel_box = requesting_object if requesting_object
      states << Analyzable::ParcelState.new(state: 'for_sale', user_id: user.id)
    end

    def set_parcel_for_sale
      self.requesting_object = user.parcel_boxes.where(object_key: parcel_box_key).first
      states.last.update(closed_at: Time.current,
                         duration: (Time.current - states.last.created_at))
      # puts self.states.last.inspect
      handle_parcel_opening
    end

    def handle_parcel_owner_change
      parcel_box&.destroy
      states.last.update(closed_at: Time.current,
                         duration: (Time.current - states.last.created_at))
      state = owner_key.nil? ? :open : :occupied
      states << Analyzable::ParcelState.new(state: state, user_id: user.id)
    end

    def handle_tier_payment
      added_time = tier_payment.to_f / weekly_tier
      # requesting_object = AbstractWebObject.find_by_object_key(tier_payment['object_key'])
      self.expiration_date = expiration_date + 1.week.to_i * added_time
      user.transactions << Analyzable::Transaction.create(
        amount: tier_payment,
        target_key: owner_key,
        target_name: owner_name,
        source_key: requesting_object.object_key,
        source_name: requesting_object.object_name,
        source_type: 'tier_station',
        category: 'tier',
        description: "Tier payment from #{owner_name}"
      )
    end
  end
end
