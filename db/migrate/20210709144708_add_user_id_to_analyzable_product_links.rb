class AddUserIdToAnalyzableProductLinks < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_product_links, :user_id, :integer
  end
end
