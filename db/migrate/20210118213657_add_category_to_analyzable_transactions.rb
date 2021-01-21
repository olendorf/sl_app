class AddCategoryToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :category, :integer, default: 0, null: false
  end
end
