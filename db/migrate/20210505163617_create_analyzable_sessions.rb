class CreateAnalyzableSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_sessions do |t|
      t.string :avatar_name
      t.string :avatar_key
      t.datetime :stopped_at
      t.integer :duration
      t.integer :sessionable_id
      t.string :sessionable_type

      t.timestamps
    end
  end
end
