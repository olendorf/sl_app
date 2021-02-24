class CreateAnalyzableInventories < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_inventories do |t|
      t.string :inventory_name
      t.string :inventory_description
      t.integer :price
      t.integer :user_id
      t.integer :server_id
      t.integer :inventory_type
      t.integer :owner_perms
      t.integer :next_perms

      t.timestamps
    end
  end
end
