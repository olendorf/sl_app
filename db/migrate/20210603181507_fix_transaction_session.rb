class FixTransactionSession < ActiveRecord::Migration[6.0]
  def change
    remove_column :analyzable_transactions, :sessionable_id, :integer
    add_column :analyzable_transactions, :session_id, :integer
  end
end
