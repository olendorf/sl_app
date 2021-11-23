class CreateRezzableShopRentalBoxes < ActiveRecord::Migration[6.1]
  def change
    create_table :rezzable_shop_rental_boxes do |t|
      t.integer :weekly_rent
      t.integer :allowed_land_impact
      t.integer :current_land_impact
      t.datetime :expiration_date
      t.string :renter_name
      t.string :renter_key
      t.string :current_state, default: 'open'

      t.timestamps
    end
  end
end
