FactoryBot.define do
  factory :analyzable_detection, class: 'Analyzable::Detection' do
    visit_id { 1 }
    position { "MyString" }
  end
end
