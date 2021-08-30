# frozen_string_literal: true

module Rezzable
  # Model for boxes that go on inworld parcels for rent that monitor
  # when the parcel is sold and rented.
  class ParcelBox < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior

    OBJECT_WEIGHT = 1
    belongs_to :parcel, class_name: 'Analyzable::Parcel'

    def response_data
      open_parcels = {}
      Analyzable::Parcel.open_parcels(user, region).each { |p| open_parcels[p.parcel_name] = p.id }
      {
        api_key: self.api_key,
        open_parcels: open_parcels
      }
    end
  end
end
