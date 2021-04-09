class AddStartStopTimesToAnalyzableVisit < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_visits, :start_time, :datetime
    add_column :analyzable_visits, :stop_time, :datetime
    add_column :analyzable_visits, :duration, :integer
    add_column :analyzable_visits, :user_id, :integer
    add_column :analyzable_visits, :region, :string
  end
end
