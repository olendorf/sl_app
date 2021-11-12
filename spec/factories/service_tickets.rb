FactoryBot.define do
  factory :service_ticket do    
    transient do
      first_name { Faker::Name.first_name }
      last_name { rand < 0.5 ? Faker::Name.last_name : 'Resident' }
    end
    client_name { "#{first_name} #{last_name}" }
    title { Faker::Hipster.sentence }
    description { Faker::Lorem.paragraph }
    client_key { SecureRandom.uuid }
    status { ['open', 'closed'].sample }
    
    factory :open_ticket do 
      status { 'open' }
    end
    
    factory :closed_ticket do 
      status { 'closed' }
    end
    
  end
end
