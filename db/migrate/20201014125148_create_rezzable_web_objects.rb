class CreateRezzableWebObjects < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_web_objects do |t|

      t.timestamps
    end
  end
end
