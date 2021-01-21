class AddSourceTypeToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :source_type, :string
  end
end
