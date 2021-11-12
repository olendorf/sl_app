class AddClientNameToServiceTickets < ActiveRecord::Migration[6.1]
  def change
    add_column :service_tickets, :client_name, :string
  end
end
