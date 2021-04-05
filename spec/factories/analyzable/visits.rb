# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_visit, class: 'Analyzable::Visit' do
    object_id { 1 }
    avatar_key { 'MyString' }
    avatar_name { 'MyString' }
  end
end
