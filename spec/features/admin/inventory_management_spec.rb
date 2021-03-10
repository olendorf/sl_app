# frozen_string_literal: true

require 'rails_helper'
# Capybara.register_driver :selenium do |app|
#     Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

RSpec.feature 'Inventory management', type: :feature do  

  
  
  let(:owner) { FactoryBot.create :owner }
  let(:user) { FactoryBot.create :active_user }
  let(:server) {
    server = FactoryBot.build :server, user_id: owner.id
    server.save
    server.inventories << FactoryBot.build(:inventory)
    server.inventories << FactoryBot.build(:inventory)
    server
  }
  # let(:uri_regex) do
  #   %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}\?
  #     auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  # end
  let(:uri_regex) do 
    %r{https://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/
    inventory/[a-zA-Z\s%0-9]+\?auth_digest=[a-f0-9]+&auth_time=[0-9]+}x
  end

  before(:each) do
    login_as(owner, scope: :user)
  end

  
  
  scenario 'User deletes an inventory from the inventory show page' do 
    stub = stub_request(:delete, uri_regex)
    server
    visit(admin_inventory_path(server.inventories.first))
    

    click_on('Delete Inventory')


    expect(stub).to have_been_requested
  end
end