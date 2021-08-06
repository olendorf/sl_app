# frozen_string_literal: true

module Analyzable
  # Model for inworld parcels for rent.
  class Parcel < ApplicationRecord
    has_one :parcel_box, class_name: 'Rezzable::ParcelBox'
  end
end
