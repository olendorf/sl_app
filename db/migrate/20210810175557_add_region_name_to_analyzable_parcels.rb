class AddRegionNameToAnalyzableParcels < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_parcels, :region, :string
    add_column :analyzable_parcels, :user_id, :integer
    remove_column :rezzable_parcel_boxes, :parcel_id, :integer
    add_column :analyzable_parcels, :parcel_box_id, :integer
  end
end
