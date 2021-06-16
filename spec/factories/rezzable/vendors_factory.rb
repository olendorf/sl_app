FactoryBot.define do
  factory :rezzable_vendor, aliases: [:vendor], class: 'Rezzable::Vendor' do
    association :abstract_web_object, factory: :abstract_web_object
  end
end
