# frozen_string_literal: true

FactoryBot.define do
  factory :abstract_web_object do
    object_name { Faker::Commerce.product_name[0, 63] }
    object_key { SecureRandom.uuid }
    description { rand < 0.5 ? '' : Faker::Hipster.sentence[0, 126] }
    region do
      Faker::Lorem.words(
        number: rand(1..3)
      ).map(&:capitalize).join(' ')
    end
    position do
      { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.transform_values do |v|
        v.round(4)
      end.to_json
    end
    api_key { SecureRandom.uuid }
    url { "https://sim3015.aditi.lindenlab.com:12043/cap/#{object_key}" }
    major_version { rand(0..2) }
    minor_version { rand(0..12) }
    patch_version { rand(0..100) }
  end
end
