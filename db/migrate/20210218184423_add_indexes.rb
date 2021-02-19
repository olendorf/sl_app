class AddIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :abstract_web_objects, :object_name
    add_index :abstract_web_objects, :object_key
    add_index :abstract_web_objects, :region
    add_index :abstract_web_objects, :user_id
    add_index :abstract_web_objects, :description
    
    add_index :analyzable_transactions, :description
    add_index :analyzable_transactions, :amount
    add_index :analyzable_transactions, :user_id
    add_index :analyzable_transactions, :source_key
    add_index :analyzable_transactions, :source_name
    add_index :analyzable_transactions, :source_type
    add_index :analyzable_transactions, :transaction_key
    add_index :analyzable_transactions, :category
    add_index :analyzable_transactions, :target_name
    add_index :analyzable_transactions, :target_key
    
    add_index :avatars, :avatar_key
    add_index :avatars, :avatar_name
    add_index :avatars, :display_name
    
    add_index :splits, :percent
    add_index :splits, :target_name
    add_index :splits, :target_key
    
    add_index :users, :role
    add_index :users, :account_level
    add_index :users, :expiration_date
  end
end
