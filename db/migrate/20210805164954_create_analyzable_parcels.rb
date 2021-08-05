class CreateAnalyzableParcels < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_parcels do |t|
      t.string :parcel_name
      t.string :description
      t.string :owner_key
      t.string :owner_name
      t.integer :area
      t.integer :max_prims
      t.string :rating
      t.string :parcel_key
      t.integer :weekly_tier
      t.integer :purchase_price

      t.timestamps
    end
  end
end
