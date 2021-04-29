# frozen_string_literal: true

FactoryBot.define do
  factory :rezzable_tip_jar, aliases: [:tip_jar], class: 'Rezzable::TipJar' do
    association :abstract_web_object, factory: :abstract_web_object
    split_percent { rand(0..80) }
  end
end
