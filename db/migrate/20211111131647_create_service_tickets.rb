class CreateServiceTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :service_tickets do |t|
      t.string :title
      t.text :description
      t.string :client_key
      t.integer :user_id
      t.integer :status, default: 1

      t.timestamps
    end
  end
end
