# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_transaction, class: 'Analyzable::Transaction' do
    name { Faker::Resaurant.name }
    description { Faker::Resaurant.description }
    amount { rand(-1000..1000) }
    source_key { SecureRandom.uuid }
    source_name { Faker::Commerce.product_name }
  end
end
