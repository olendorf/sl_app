class AddSettingsToTipJar < ActiveRecord::Migration[6.1]
  def change
    add_column :rezzable_tip_jars, :show_last_tip, :boolean, default: true
    add_column :rezzable_tip_jars, :show_last_tipper, :boolean, default: true
    add_column :rezzable_tip_jars, :show_total, :boolean, default: true
    add_column :rezzable_tip_jars, :sensor_node, :integer, default: 0
    add_column :rezzable_tip_jars, :inactive_time, :integer, defaulit: 60
    add_column :rezzable_tip_jars, :show_duration, :boolean, default: false
  end
end
