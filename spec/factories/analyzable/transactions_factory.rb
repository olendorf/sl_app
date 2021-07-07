# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_transaction, aliases: [:transaction], class: 'Analyzable::Transaction' do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? 'Resident' : Faker::Name.last_name }
    end
    target_name { "#{first_name} #{last_name}" }
    target_key { SecureRandom.uuid }
    description { Faker::Restaurant.description }
    amount { rand(-1000..1000) }
    transaction_key { rand < 0.25 ? SecureRandom.uuid : nil }
    category { (Analyzable::Transaction.categories.keys - ['tip']).sample }

    factory :donation do
      category { 'donation' }
      amount { rand(1..1000) }
    end

    factory :tip do
      category { 'tip' }
      amount { rand(1..1000) }
    end
    
    factory :sale do 
      category { 'sale' }
      amount { rand(1..1000) }
    end
  end
end
