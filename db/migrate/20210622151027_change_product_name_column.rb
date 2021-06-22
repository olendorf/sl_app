class ChangeProductNameColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :analyzable_products, :name, :product_name
  end
end
