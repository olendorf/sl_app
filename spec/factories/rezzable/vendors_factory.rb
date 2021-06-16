FactoryBot.define do
  factory :rezzable_vendor, aliases: [:vendor], class: 'Rezzable::Vendor' do
    association :abstract_web_object, factory: :abstract_web_object
    inventory_name { Faker::Commerce.product_name }
    price { rand(1..5000) }
  end
end
