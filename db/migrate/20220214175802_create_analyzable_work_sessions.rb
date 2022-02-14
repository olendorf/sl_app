class CreateAnalyzableWorkSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :analyzable_work_sessions do |t|
      t.integer :employee_id
      t.string :employee_name
      t.string :employee_key
      t.integer :duration
      t.datetime :start_time
      t.datetime :stop_time
      t.integer :pay

      t.timestamps
    end
  end
end
