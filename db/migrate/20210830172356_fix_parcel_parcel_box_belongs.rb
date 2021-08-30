class FixParcelParcelBoxBelongs < ActiveRecord::Migration[6.0]
  def change
    remove_column :analyzable_parcels, :parcel_box_id, :integer
    add_column :rezzable_parcel_boxes, :parcel_id, :integer
  end
end
