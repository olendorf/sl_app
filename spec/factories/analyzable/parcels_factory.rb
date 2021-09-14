# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_parcel, aliases: [:parcel], class: 'Analyzable::Parcel' do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    parcel_name { Faker::Commerce.product_name }
    region { Faker::Hipster.words(number: rand(1..3)).join(' ')[0..64] }
    description { Faker::Hipster.sentence(word_count: 3) }
    area { rand(16..8192) }
    parcel_key { SecureRandom.uuid }
    weekly_tier { rand(10..2000) }
    purchase_price { rand(10..2000) }
  end
end
