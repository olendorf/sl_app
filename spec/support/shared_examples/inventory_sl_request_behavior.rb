RSpec.shared_examples 'it has inventory request behavior' do |namespace|
  let(:owner) { FactoryBot.create :owner }
  let(:user) { FactoryBot.create :active_user }
  let(:server) {
    server = FactoryBot.build :server, user_id: user.id
    server.save
    server.inventories << FactoryBot.build(:inventory)
    server.inventories << FactoryBot.build(:inventory)
    server.inventories << FactoryBot.build(:inventory)
    server.inventories << FactoryBot.build(:inventory)
    server
  }
  let(:server_2) {
    server = FactoryBot.build :server, user_id: user.id
    server.save
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
  
  let(:server_regex) do 
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  before(:each) do
    login_as(owner, scope: :user) if namespace == 'admin'
    login_as(user, scope: :user) if namespace == 'my'
  end

  
  
  scenario 'User deletes an inventory from the inventory show page' do 
    stub = stub_request(:delete, uri_regex)
    server
    visit(send("#{namespace}_inventory_path", server.inventories.first))

    click_on('Delete Inventory')


    expect(stub).to have_been_requested
  end
  
  scenario 'User moves inventory to a different server' do 
    server
    server_2
    
    stub = stub_request(:put, uri_regex).with(
      body: "{\"server_key\":\"#{server_2.object_key}\"}")
    
    visit(send("edit_#{namespace}_inventory_path", server.inventories.first))
    select server_2.object_name, from: 'analyzable_inventory_server_id'
    click_on('Update Inventory')
    expect(stub).to have_been_requested
  end
  
  scenario 'User deletes inventory from server show page' do 
    stub = stub_request(:delete, uri_regex)
    server
    visit(send("#{namespace}_server_path", server))
    first('.delete_link').click
    expect(stub).to have_been_requested
  end
  
  scenario 'Deletes inventories from server edit page' do 
    stub = stub_request(:delete, uri_regex)
    stub_request(:put, server_regex)
    server
    visit(send("edit_#{namespace}_server_path", server))
    check("rezzable_server_inventories_attributes_0__destroy")
    check("rezzable_server_inventories_attributes_1__destroy")
    click_on('Update Server')
    expect(stub).to have_been_requested.times(2)
  end
  
end