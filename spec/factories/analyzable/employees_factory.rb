# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_employee, class: 'Analyzable::Employee' do\
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    avatar_name { "#{first_name} #{last_name}" }
    avatar_key { SecureRandom.uuid }
    hourly_pay { rand(50..200) }
    max_hours { rand(10..40) }
  end
end
