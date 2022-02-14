class CreateAnalyzableEmployees < ActiveRecord::Migration[6.1]
  def change
    create_table :analyzable_employees do |t|
      t.string :avatar_name
      t.string :avatar_key
      t.integer :hourly_pay
      t.integer :max_hours
      t.integer :pay_owed, default: 0
      t.float :hours_worked, default: 0
      t.integer :user_id

      t.timestamps
    end
  end
end
