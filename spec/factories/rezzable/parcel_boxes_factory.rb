FactoryBot.define do
  factory :rezzable_parcel_box,aliases: [:parcel_box], class: 'Rezzable::ParcelBox' do
    association :abstract_web_object, factory: :abstract_web_object
  end
end
