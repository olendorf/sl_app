# frozen_string_literal: true

FactoryBot.define do
  factory :split do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    target_name { "#{first_name} #{last_name}" }
    target_key { SecureRandom.uuid }
    percent { rand(1..100) }
  end
end
