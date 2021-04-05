class CreateRezzableTrafficCops < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_traffic_cops do |t|
      t.boolean       :power,               defaut: false
      t.integer       :sensor_mode,         default: 0
      t.integer       :security_mode,       default: 0
      t.string        :first_visit_message  
      t.string        :repeat_visit_message 
      

      t.timestamps
    end
  end
end
