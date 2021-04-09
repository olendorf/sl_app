class AddAccessModeToRezzableTrafficCops < ActiveRecord::Migration[6.0]
  def change
    add_column :rezzable_traffic_cops, :access_mode, :integer, default: 0
    add_column :rezzable_traffic_cops, :inventory_to_give, :string
  end
end
