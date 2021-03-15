# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InventorySlRequest do
  let(:user) { FactoryBot.create :user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  before(:each) do
    4.times do |i|
      server.inventories << FactoryBot.build(:inventory, inventory_name: "inventory #{i}")
    end
  end

  let(:uri_regex) do
    %r{https://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/
    inventory/[a-zA-Z\s%0-9]+\?auth_digest=[a-f0-9]+&auth_time=[0-9]+}x
  end

  describe '.delete_inventory' do
    context 'deleting one inventory' do
      it 'should make the request to the object' do
        stub = stub_request(:delete, uri_regex)
        InventorySlRequest.delete_inventory(server.inventories.sample)
        expect(stub).to have_been_requested
      end
    end
    
    context 'error occurs' do 
      it 'should raise an error' do 
        stub_request(:delete, uri_regex).to_return(body: "abc", status: 400)
        expect{
          InventorySlRequest.delete_inventory(server.inventories.sample)
          }.to raise_error(RestClient::ExceptionWithResponse)
      end
    end
  end

  describe '.batch_destroy' do
    it 'should make the request for each item' do
      stub = stub_request(:delete, uri_regex)
      ids = server.inventories.sample(3).collect(&:id)
      InventorySlRequest.batch_destroy(ids)
      expect(stub).to have_been_requested.times(3)
    end
  end
  
  describe '.move_inventory' do 
    let(:server_two) { FactoryBot.create :server }
    it 'should send the request ' do 
      stub = stub_request(:put, uri_regex)
      InventorySlRequest.move_inventory(server.inventories.sample, server.id)
      expect(stub).to have_been_requested
    end
    
    context 'error occurs' do 
      it 'should raise an error' do 
        stub_request(:put, uri_regex).to_return(body: "abc", status: 400)
        expect{
          InventorySlRequest.move_inventory(server.inventories.sample, server_two.id)
          }.to raise_error(RestClient::ExceptionWithResponse)
      end
    end
  end
  
  describe '.give' do 
    it 'should make the request' do 
      
    end
  end
end
