# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    text { Faker::Hipster.sentence }
    author { "#{first_name} #{last_name}" }
  end
end
