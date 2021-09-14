class CreateAnalyzableParcelStates < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_parcel_states do |t|
      t.integer :duration
      t.datetime :closed_at
      t.integer :state
      t.integer :parcel_id

      t.timestamps
    end
  end
end
