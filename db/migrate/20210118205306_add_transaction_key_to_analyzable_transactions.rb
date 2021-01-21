class AddTransactionKeyToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :transaction_key, :string
  end
end
