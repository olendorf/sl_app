# frozen_string_literal: true

FactoryBot.define do
  factory :analyzable_inventory, aliases: [:inventory], class: 'Analyzable::Inventory' do
    inventory_name { Faker::Commerce.product_name }
    inventory_type { Analyzable::Inventory.inventory_types.keys.sample }
    owner_perms {  Analyzable::Inventory::PERMS.values.sample(rand(1..4)).sum }
    next_perms { Analyzable::Inventory::PERMS.values.sample(rand(1..4)).sum }

    factory :sellable_inventory do
      price { rand(1..5000) }
    end
  end
end
