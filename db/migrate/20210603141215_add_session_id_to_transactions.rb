class AddSessionIdToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :sessionable_id, :integer
  end
end
