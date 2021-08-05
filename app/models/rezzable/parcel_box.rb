# frozen_string_literal: true

module Rezzable
  # Model for boxes that go on inworld parcels for rent that monitor
  # when the parcel is sold and rented.
  class ParcelBox < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior

    OBJECT_WEIGHT = 1
    belongs_to :parcel, class_name: 'Analyzable::Parcel'
  end
end
