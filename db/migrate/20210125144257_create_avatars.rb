class CreateAvatars < ActiveRecord::Migration[6.0]
  def change
    create_table :avatars do |t|
      t.string :avatar_key
      t.string :avatar_name
      t.string :display_name
      t.date :rezday

      t.timestamps
    end
  end
end
