FactoryBot.define do
  factory :analyzable_inventory, class: 'Analyzable::Inventory' do
    inventory_name { "MyString" }
    inventory_description { "MyString" }
    price { 1 }
    user_id { 1 }
    server_id { 1 }
    inventory_type { 1 }
    owner_perms { 1 }
    next_perms { 1 }
  end
end
