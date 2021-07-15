class AddRevenueToThings < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_products, :revenue, :integer, default: 0
    add_column :analyzable_inventories, :revenue, :integer, default: 0
    add_column :rezzable_vendors, :revenue, :integer, default: 0
    add_column :abstract_web_objects, :transactions_count, :integer, default: 0
  end
end
