# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_product_link, aliases: [:product_link], class: 'Analyzable::ProductLink' do
    link_name { Faker::Commerce.product_name }
  end
end
