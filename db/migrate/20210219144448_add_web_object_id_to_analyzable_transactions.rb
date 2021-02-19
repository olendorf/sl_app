class AddWebObjectIdToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :web_object_id, :integer
  end
end
