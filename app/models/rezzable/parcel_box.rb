class Rezzable::ParcelBox < ApplicationRecord
  acts_as :abstract_web_object
  
  include RezzableBehavior
  include TransactableBehavior

  OBJECT_WEIGHT = 1
  belongs_to :parcel, class_name: 'Analyzable::Parcel'
end
