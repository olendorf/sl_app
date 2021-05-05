FactoryBot.define do
  factory :analyzable_session, aliases: [:session], class: 'Analyzable::Session' do
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    avatar_name { "#{first_name} #{last_name}" }
    avatar_key { SecureRandom.uuid }
  end
end
