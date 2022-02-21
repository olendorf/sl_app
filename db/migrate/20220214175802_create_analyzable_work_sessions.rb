class CreateAnalyzableWorkSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :analyzable_work_sessions do |t|
      t.integer :employee_id
      t.float :duration
      t.datetime :stopped_at
      t.integer :pay

      t.timestamps
    end
  end
end
