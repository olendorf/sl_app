# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_product_name, class: 'Analyzable::ProductName' do
    link_name { Faker::Commerce.product_name }
  end
end
