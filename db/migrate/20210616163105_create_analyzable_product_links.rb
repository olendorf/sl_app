class CreateAnalyzableProductLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_product_links do |t|
      t.integer :product_id
      t.string :link_name

      t.timestamps
    end
  end
end
