class AddVisitUsSlurlToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :visit_us_slurl, :string
  end
end
