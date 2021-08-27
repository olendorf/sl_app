FactoryBot.define do
  factory :analyzable_parcel_state, class: 'Analyzable::ParcelState' do
    duration { 1 }
    closed_at { "" }
    state { 1 }
  end
end
