class AddPreviousBalanceToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :previous_balance, :integer
  end
end
