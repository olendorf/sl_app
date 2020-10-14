FactoryBot.define do
  factory :rezzable_web_object, class: 'Rezzable::WebObject' do
    association :abstract_web_object, factory: :abstract_web_object
  end
end
