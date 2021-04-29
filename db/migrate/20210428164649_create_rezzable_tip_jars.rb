class CreateRezzableTipJars < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_tip_jars do |t|
      t.integer :split_percent
      t.integer :access_mode, default: 0
      t.string :logged_in_key
      t.string :logged_in_name
      t.string :thank_you_message

      t.timestamps
    end
  end
end
