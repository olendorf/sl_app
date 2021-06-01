class FixTransactions < ActiveRecord::Migration[6.0]
  def change
    remove_column :analyzable_transactions, :web_object_id, :integer
    add_column :analyzable_transactions, :transactable_id, :integer
    add_column :analyzable_transactions, :transactable_type, :string
  end
end
