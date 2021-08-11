# frozen_string_literal: true

module Analyzable
  # Model for inworld parcels for rent.
  class Parcel < ApplicationRecord
    belongs_to :parcel_box, class_name: 'Rezzable::ParcelBox'
    
    def self.open_parcels(user, region)
      user.parcels.where(region: region, parcel_box_id: nil)
    end
  end
end
