# frozen_string_literal: true

FactoryBot.define do
  factory :rezzable_donation_box, aliases: [:donation_box], class: 'Rezzable::DonationBox' do
    association :abstract_web_object, factory: :abstract_web_object
    goal { rand <= 0.75 ? rand(10_000) : nil }
    dead_line { rand <= 0.75 ? Time.now + rand(365).days.to_i : nil }
    response { 'Thank you' }
  end
end
