class RemoveDurationFromAnalyzableParcelStates < ActiveRecord::Migration[6.0]
  def change
    remove_column :analyzable_parcel_states, :duration, :integer
  end
end
