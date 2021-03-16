class Rezzable::DonationBox < ApplicationRecord
  
    acts_as :abstract_web_object
    
    def last_donation
      transactions.to_ary.sort_by(&:created_at).last
    end
    
    def total_donations
      transactions.sum(:amount)
    end
    
    def largest_donation
      transactions.to_ary.sort_by(&:amount).last
    end
    
    def biggest_donor
      data = transactions.group(:target_key, :target_name).sum(:amount).max_by { |k, v| v }
      { avatar_key: data.first.first, avatar_name: data.first.second, amount: data.last }
    end
end
