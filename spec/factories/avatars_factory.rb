# frozen_string_literal: true

FactoryBot.define do
  factory :avatar do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    avatar_name { "#{first_name} #{last_name}" }
    avatar_key { SecureRandom.uuid }
    display_name { Faker::Name.name }
    rezday { Date.today - rand(10_000) }
  end
end
