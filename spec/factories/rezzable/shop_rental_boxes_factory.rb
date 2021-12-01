# frozen_string_literal: true

FactoryBot.define do
  factory :rezzable_shop_rental_box, aliases: [:shop_rental_box],
                                     class: 'Rezzable::ShopRentalBox' do
    association :abstract_web_object, factory: :abstract_web_object
    weekly_rent { rand(100..1000) }
    allowed_land_impact { rand(100 - 500) }
    
    factory :rented_shop_rental_box do 
      transient do
        first_name { Faker::Name.first_name }
        last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
      end
      current_land_impact { rand(0..100) }
      expiration_date { 1.week.from_now }
    end
  end
end
