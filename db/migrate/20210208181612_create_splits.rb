class CreateSplits < ActiveRecord::Migration[6.0]
  def change
    create_table :splits do |t|
      t.integer :percent
      t.integer :splittable_id
      t.string :splittable_type

      t.timestamps
    end
  end
end
