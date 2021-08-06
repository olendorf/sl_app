class CreateRezzableTierStations < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_tier_stations do |t|

      t.timestamps
    end
  end
end
