class CreateAnalyzableProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_products do |t|
      t.integer :user_id
      t.string :image_key
      t.string :name

      t.timestamps
    end
  end
end
