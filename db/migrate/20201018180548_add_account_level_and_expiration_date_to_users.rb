class AddAccountLevelAndExpirationDateToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :account_level, :integer, default: 0
    add_column :users, :expiration_date, :datetime
  end
end
