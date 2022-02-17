class CreateAnalyzableWorkSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :analyzable_work_sessions do |t|
      t.integer :employee_id
      t.integer :duration
      t.datetime :stop_time
      t.integer :pay

      t.timestamps
    end
  end
end
