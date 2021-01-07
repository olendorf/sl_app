# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:inactive_user] do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    avatar_name { "#{first_name} #{last_name}" }
    avatar_key { SecureRandom.uuid }
    password { 'Pa$sW0rd' }

    factory :active_user do
      account_level { 1 }
      expiration_date { 1.month.from_now }
    end

    factory :prime do
      role { :prime }
    end

    factory :admin do
      role { :admin }
    end

    factory :owner do
      role { :owner }
    end
  end
end
