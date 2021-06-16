FactoryBot.define do
  factory :analyzable_product, aliases: [:product], class: 'Analyzable::Product' do
    name { Faker::Commerce.product_name }
  end
end
