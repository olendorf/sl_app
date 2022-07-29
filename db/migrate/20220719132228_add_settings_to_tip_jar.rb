class AddSettingsToTipJar < ActiveRecord::Migration[6.1]
  def change
    add_column :rezzable_tip_jars, :show_last_tip, :boolean, default: true
    add_column :rezzable_tip_jars, :show_last_tipper, :boolean, default: true
    add_column :rezzable_tip_jars, :show_total, :boolean, default: true
    add_column :rezzable_tip_jars, :sensor_mode, :integer, default: 0
    add_column :rezzable_tip_jars, :inactive_time, :integer, default: 60
    add_column :rezzable_tip_jars, :show_duration, :boolean, default: false
    change_column_default :rezzable_tip_jars, :split_percent, from: nil, to: 100
    add_column :rezzable_tip_jars, :show_hover_text, :boolean, default: true
    add_column :rezzable_tip_jars, :default_tip, :integer, default: 50
    add_column :rezzable_tip_jars, :quick_pay_1, :integer, default: 100
    add_column :rezzable_tip_jars, :quick_pay_2, :integer, default: 200
    add_column :rezzable_tip_jars, :quick_pay_3, :integer, default: 300
    add_column :rezzable_tip_jars, :quick_pay_4, :integer, default: 400
  end
end
