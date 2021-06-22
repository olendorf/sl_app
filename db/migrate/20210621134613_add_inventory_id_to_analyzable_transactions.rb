class AddInventoryIdToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :inventory_id, :integer
    add_column :analyzable_transactions, :product_id, :integer
  end
end
