class AddSettingsToRezzableDonationBoxes < ActiveRecord::Migration[6.1]
  def change
    add_column :rezzable_donation_boxes, :default_price, :integer, default: -1
    add_column :rezzable_donation_boxes, :quick_pay_1, :integer, default: -2
    add_column :rezzable_donation_boxes, :quick_pay_2, :integer, default: -2
    add_column :rezzable_donation_boxes, :quick_pay_3, :integer, default: -2
    add_column :rezzable_donation_boxes, :quick_pay_4, :integer, default: -2
    
  end
end
