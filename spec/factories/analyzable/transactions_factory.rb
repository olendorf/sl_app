# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_transaction, aliases: [:transaction], class: 'Analyzable::Transaction' do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? 'Resident' : Faker::Name.last_name }
    end
    description { Faker::Restaurant.description }
    amount { rand(-1000..1000) }
    transaction_key { rand < 0.25 ? SecureRandom.uuid : nil }
    category { Analyzable::Transaction.categories.keys.sample }
  end
end
