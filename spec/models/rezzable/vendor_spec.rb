# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::Vendor, type: :model do
  it_behaves_like 'a rezzable object', :vendor, 1
  it_behaves_like 'it is a transactable', :vendor

  it { should respond_to :abstract_web_object }

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:inventory) {
    FactoryBot.create :inventory, user_id: user.id,
                                  server_id: server.id
  }

  let(:vendor) {
    FactoryBot.create :vendor, user_id: user.id,
                               server_id: server.id,
                               inventory_name: inventory.inventory_name
  }

  describe '#price' do
    it 'should return the price' do
      expect(vendor.price).to eq inventory.price
    end
  end

  describe '#inventory' do
    it 'should return the inventory' do
      expect(vendor.inventory).to eq inventory
    end
  end
end
