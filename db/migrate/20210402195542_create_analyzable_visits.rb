class CreateAnalyzableVisits < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_visits do |t|
      t.integer :web_object_id
      t.string :avatar_key
      t.string :avatar_name

      t.timestamps
    end
  end
end
