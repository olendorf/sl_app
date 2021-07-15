class AddProductLinksCountToAnalyzableProdcut < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_products, :product_links_count, :integer
    add_column :analyzable_inventories, :transactions_count, :integer, default: 0
    add_column :analyzable_products, :transactions_count, :integer, default: 0
  end
end
