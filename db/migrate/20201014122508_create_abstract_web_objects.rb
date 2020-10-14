class CreateAbstractWebObjects < ActiveRecord::Migration[6.0]
  def change
    create_table :abstract_web_objects do |t|
      t.string :object_name,  null: false
      t.string :object_key,   null: false
      t.string :description
      t.string :region,       null: false
      t.string :position,      null: false
      t.string :url,          null: false
      t.string :api_key,      null: false
      t.integer :user_id      
      t.integer :actable_id
      t.string :actable_type
      t.datetime :pinged_at
      t.integer :major_version
      t.integer :minor_version
      t.integer :patch_version

      t.timestamps
    end
  end
end
