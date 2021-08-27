class Analyzable::ParcelState < ApplicationRecord
  belongs_to :parcel, class_name: 'Analyzable::Parcel'
  
  enum state: %i[open for_sale occupied]
end
