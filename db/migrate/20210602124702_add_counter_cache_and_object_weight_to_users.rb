class AddCounterCacheAndObjectWeightToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :web_objects_count, :integer, default: 0
    add_column :users, :web_objects_weight, :integer, default: 0
  end
end
