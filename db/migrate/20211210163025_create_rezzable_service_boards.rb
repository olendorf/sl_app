class CreateRezzableServiceBoards < ActiveRecord::Migration[6.1]
  def change
    create_table :rezzable_service_boards do |t|
      t.integer :weekly_rent
      t.datetime :expiration_date
      t.string :renter_name
      t.string :renter_key
      t.string :current_state, default: 'for_rent'
      t.string :image_name
      t.string :image_key
      t.string :notecard_name

      t.timestamps
    end
  end
end
