class CreateAnalyzableTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_transactions do |t|
      t.string :name
      t.text :description
      t.integer :amount
      t.integer :balance
      t.integer :user_id
      t.integer :transaction_id
      t.string :source_key
      t.string :source_name

      t.timestamps
    end
  end
end
