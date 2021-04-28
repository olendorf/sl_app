FactoryBot.define do
  factory :rezzable_tip_jar, class: 'Rezzable::TipJar' do
    split_percent { 1 }
    access_mode { 1 }
    logged_in_key { "MyString" }
    logged_in_name { "MyString" }
    thank_you_message { "MyString" }
  end
end
