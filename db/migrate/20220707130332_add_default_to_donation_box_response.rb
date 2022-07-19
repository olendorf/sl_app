class AddDefaultToDonationBoxResponse < ActiveRecord::Migration[6.1]
  def change
    change_column :rezzable_donation_boxes, :response, :string, default: "Thank you!"
  end
end
