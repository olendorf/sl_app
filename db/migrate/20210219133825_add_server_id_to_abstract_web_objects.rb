class AddServerIdToAbstractWebObjects < ActiveRecord::Migration[6.0]
  def change
    add_column :abstract_web_objects, :server_id, :integer
  end
end
