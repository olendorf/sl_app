
class CreateListableAvatars < ActiveRecord::Migration[6.0]
  def change
    create_table :listable_avatars do |t|
      t.string :avatar_name
      t.string :avatar_key
      t.string :list_name
      t.integer :listable_id
      t.string :listable_type

      t.timestamps
    end
  end
end
