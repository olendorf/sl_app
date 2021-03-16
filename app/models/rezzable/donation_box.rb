class Rezzable::DonationBox < ApplicationRecord
  
    acts_as :abstract_web_object
    
    def last_donation
      transactions.to_ary.sort_by(&:created_at).last
    end
    
    def total_donations
      transactions.sum(:amount)
    end
end
