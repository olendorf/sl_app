class CreateRezzableTimeCops < ActiveRecord::Migration[6.1]
  def change
    create_table :rezzable_time_cops do |t|
      t.boolean :autopay, default: false

      t.timestamps
    end
  end
end
