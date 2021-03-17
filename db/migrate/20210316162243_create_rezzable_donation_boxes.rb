class CreateRezzableDonationBoxes < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_donation_boxes do |t|
      t.boolean           :show_last_donation,    default: false
      t.boolean           :show_last_donor,       default: false
      t.boolean           :show_total ,           default: true    
      t.boolean           :show_largest_donation, default: false
      t.integer           :total,                 default: 0
      t.integer           :goal
      t.datetime          :dead_line

      t.timestamps
    end
  end
end
