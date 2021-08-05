class CreateRezzableParcelBoxes < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_parcel_boxes do |t|
      t.integer :parcel_id
      t.timestamps
    end
  end
end
