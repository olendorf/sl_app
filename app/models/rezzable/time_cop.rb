class Rezzable::TimeCop < ApplicationRecord
  acts_as :abstract_web_object

  include RezzableBehavior
  
  OBJECT_WEIGHT = 4
end
