FactoryBot.define do
  factory :rezzable_server, aliases: [:server], class: 'Rezzable::Server' do
    association :abstract_web_object, factory: :abstract_web_object
  end
end
