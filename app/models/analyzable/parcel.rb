# frozen_string_literal: true

module Analyzable
  class Parcel < ApplicationRecord
    has_one :parcel_box, class_name: 'Rezzable::ParcelBox'
  end
end
