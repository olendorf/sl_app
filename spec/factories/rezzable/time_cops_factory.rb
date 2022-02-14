FactoryBot.define do
  factory :rezzable_time_cop, aliases: [:time_cop], class: 'Rezzable::TimeCop' do
    association :abstract_web_object, factory: :abstract_web_object
    autopay { 0 }
  end
end
