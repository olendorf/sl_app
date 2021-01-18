# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_transaction, aliases: [:transaction], class: 'Analyzable::Transaction' do
    name { Faker::Restaurant.name }
    description { Faker::Restaurant.description }
    amount { rand(-1000..1000) }
    source_key { SecureRandom.uuid }
    source_name { Faker::Commerce.product_name }
  end
end
