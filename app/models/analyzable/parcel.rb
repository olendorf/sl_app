# frozen_string_literal: true

module Analyzable
  # Model for inworld parcels for rent.
  class Parcel < ApplicationRecord
    
    before_update :handle_tier_payment, if: :tier_payment
    before_update :delete_parcel_box, if: :owner_key
    
    belongs_to :parcel_box, class_name: 'Rezzable::ParcelBox'
    belongs_to :user
    has_many :states, class_name: 'Analyzable::ParcelState'
    
    attr_accessor :tier_payment, :requesting_object

    def self.open_parcels(user, region)
      user.parcels.where(region: region, parcel_box_id: nil, owner_key: nil)
    end
    
    def delete_parcel_box
      self.parcel_box.destroy if self.parcel_box
    end
    
    
    def handle_tier_payment
      added_time = tier_payment.to_f/self.weekly_tier
      # requesting_object = AbstractWebObject.find_by_object_key(tier_payment['object_key'])
      self.expiration_date = self.expiration_date + 1.week.to_i * added_time
      self.user.transactions << Analyzable::Transaction.new(
        amount: tier_payment,
        target_key: self.owner_key,
        target_name: self.owner_name,
        source_key: requesting_object.object_key,
        source_name: requesting_object.object_name,
        source_type: 'tier_station',
        category: 'tier',
        description: "Tier payment from #{self.owner_name}"
      )
    end
  end
end
