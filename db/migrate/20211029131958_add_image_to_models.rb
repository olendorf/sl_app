class AddImageToModels < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :image_key, :string
    add_column :users, :business_name, :string
    add_column :users, :default_image_key, :string
    add_column :analyzable_parcels, :image_key, :string
    
    
  end
end
