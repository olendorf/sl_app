class Analyzable::ParcelState < ApplicationRecord
  belongs_to :parcel, class_name: 'Analyzable::Parcel'
end
