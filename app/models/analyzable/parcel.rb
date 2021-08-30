# frozen_string_literal: true

module Analyzable
  # Model for inworld parcels for rent.
  class Parcel < ApplicationRecord
    
    # before_create :add_open_state
    
    before_update :handle_tier_payment, if: :tier_payment
    before_update :handle_parcel_sale, if: :owner_key_changed?
    
    has_one :parcel_box, class_name: 'Rezzable::ParcelBox', inverse_of: :parcel
    belongs_to :user
    has_many :states, class_name: 'Analyzable::ParcelState', dependent: :destroy
    
    attr_accessor :tier_payment, :requesting_object
    def self.open_parcels(user, region)
      user.parcels.includes(:parcel_box).where(owner_key: nil, region: region, rezzable_parcel_boxes: {parcel_id: nil })
    end
    
    def handle_parcel_sale
      
      self.parcel_box.destroy if self.parcel_box
      self.states.last.update(closed_at: Time.current, duration: (Time.current - self.states.last.created_at) )
      self.states << Analyzable::ParcelState.new(state: :occupied)
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
