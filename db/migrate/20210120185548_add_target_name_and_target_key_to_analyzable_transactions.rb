class AddTargetNameAndTargetKeyToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :target_name, :string
    add_column :analyzable_transactions, :target_key, :string
  end
end
