class AddParcelIdToAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_transactions, :parcel_id, :integer
  end
end
