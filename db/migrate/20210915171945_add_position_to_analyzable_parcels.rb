class AddPositionToAnalyzableParcels < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_parcels, :position, :string
  end
end
