FactoryBot.define do
  factory :comment do
    text { "MyText" }
    author { "MyString" }
    service_ticket_id { 1 }
  end
end
