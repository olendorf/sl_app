# frozen_string_literal: true

FactoryBot.define do
  factory :split do
    percent { rand(1..100) }
  end
end
