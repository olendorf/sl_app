class Analyzable::Parcel < ApplicationRecord
  has_one :parcel_box, class_name: 'Rezzable::ParcelBox'
end
