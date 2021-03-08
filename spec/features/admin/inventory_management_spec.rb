# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Inventory management', type: :feature do
  
  
  scenario 'User deletes an inventory from the inventory index page' do 
    visit(admin_inventories_path)
    first('.delete_link member_link', visible: false).click
    click_on('OK')
  end
end