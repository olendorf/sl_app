class RemoveNameFromAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    remove_column :analyzable_transactions, :name, :string
  end
end
