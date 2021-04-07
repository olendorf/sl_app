# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_detection, aliases: [:detection], class: 'Analyzable::Detection' do    
    position do
      { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.transform_values do |v|
        v.round(4)
      end.to_json
    end
  end
end
