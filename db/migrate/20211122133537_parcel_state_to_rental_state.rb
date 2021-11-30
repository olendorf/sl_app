class ParcelStateToRentalState < ActiveRecord::Migration[6.1]
  def change
    rename_table :analyzable_parcel_states, :analyzable_rental_states
    rename_column :analyzable_rental_states, :parcel_id, :rentable_id
    add_column :analyzable_rental_states, :rentable_type, :string
  end
end
