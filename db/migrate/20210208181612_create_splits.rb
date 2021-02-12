class CreateSplits < ActiveRecord::Migration[6.0]
  def change
    create_table :splits do |t|
      t.integer :percent
      t.integer :splittable_id
      t.string :splittable_type
      t.string :target_name
      t.string :target_key

      t.timestamps
    end
  end
end
