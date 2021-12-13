# frozen_string_literal: true

FactoryBot.define do
  factory :rezzable_service_board, aliases: [:service_board], class: 'Rezzable::ServiceBoard' do
    association :abstract_web_object, factory: :abstract_web_object
    weekly_rent { rand(100..1000) }

    factory :rented_service_board do
      transient do
        first_name { Faker::Name.first_name }
        last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
      end
      current_land_impact { rand(0..100) }
      expiration_date { 1.week.from_now }
      image_name { Faker::Commerce.product_name }
      image_key { SecureRandom.uuid }
      notecard_name { Faker::Commerce.product_name }
    end
  end
end
