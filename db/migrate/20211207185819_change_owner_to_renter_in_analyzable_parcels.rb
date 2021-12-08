class ChangeOwnerToRenterInAnalyzableParcels < ActiveRecord::Migration[6.1]
  def change
    rename_column :analyzable_parcels, :owner_key, :renter_key
    rename_column :analyzable_parcels, :owner_name, :renter_name
    rename_column :analyzable_parcels, :weekly_tier, :weekly_rent
  end
end
