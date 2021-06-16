class Rezzable::Vendor < ApplicationRecord

  include RezzableBehavior
  include TransactableBehavior
    
  acts_as :abstract_web_object
  
  OBJECT_WEIGHT = 1
  
  def transaction_description(transaction)
    "In world purchase by #{transaction.target_name}"
  end
  
  def transaction_category
    'sale'
  end
end
