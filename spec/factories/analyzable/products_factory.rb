# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_product, aliases: [:product], class: 'Analyzable::Product' do
    product_name { Faker::Commerce.product_name }
  end
end
