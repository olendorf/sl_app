class CreateRezzableVendors < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_vendors do |t|
      t.string :inventory_name
      t.string :image_key

      t.timestamps
    end
  end
end
