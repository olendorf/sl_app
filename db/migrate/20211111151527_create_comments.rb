class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :text
      t.string :author
      t.integer :service_ticket_id

      t.timestamps
    end
  end
end
