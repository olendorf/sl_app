# frozen_string_literal: true

FactoryBot.define do
  factory :rezzable_tier_station, aliases: [:tier_station], class: 'Rezzable::TierStation' do
    association :abstract_web_object, factory: :abstract_web_object
  end
end
