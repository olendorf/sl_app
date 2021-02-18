# frozen_string_literal: true

FactoryBot.define do
  factory :rezzable_terminal, aliases: [:terminal], class: 'Rezzable::Terminal' do
    association :abstract_web_object, factory: :abstract_web_object
  end
end
