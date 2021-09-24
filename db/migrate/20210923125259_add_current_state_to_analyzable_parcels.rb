class AddCurrentStateToAnalyzableParcels < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_parcels, :current_state, :string
  end
end
