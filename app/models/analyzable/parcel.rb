# frozen_string_literal: true

module Analyzable
  # Model for inworld parcels for rent.
  class Parcel < ApplicationRecord
    
    before_update :handle_tier_payment, if: :tier_payment
    
    belongs_to :parcel_box, class_name: 'Rezzable::ParcelBox'
    
    attr_accessor :tier_payment

    def self.open_parcels(user, region)
      user.parcels.where(region: region, parcel_box_id: nil)
    end
    
    
    def handle_tier_payment
      added_time = tier_payment.to_f/self.weekly_tier
      self.expiration_date = self.expiration_date + 1.week.to_i * added_time
    end
  end
end
