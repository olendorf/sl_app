# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::Vendor', type: :request do
  it_behaves_like 'a user object API', :vendor

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:inventory) { FactoryBot.create :inventory, server_id: server.id, price: 200 }
  let(:vendor) {
    FactoryBot.create :vendor, user_id: user.id,
                               server_id: server.id,
                               inventory_name: inventory.inventory_name
  }

  describe 'making a sale' do
    let(:path) { api_rezzable_vendor_path(vendor) }
    let(:customer) { FactoryBot.create :avatar }

    let(:atts) {
      { sale: {
        customer_name: customer.avatar_name,
        customer_key: customer.avatar_key
      } }
    }

    it 'should return OK status' do
      put path, params: atts.to_json, headers: headers(vendor)
      expect(response.status).to eq 200
    end

    it 'should add the transaction to the inventory' do
      put path, params: atts.to_json, headers: headers(vendor)
      expect(inventory.reload.sales.size).to eq 1
    end

    context 'there is a related product' do
      before(:each) do
        @product = FactoryBot.create :product, user_id: user.id
        FactoryBot.create :product_link, product_id: @product.id,
                                         link_name: inventory.inventory_name
      end

      it 'should add the transaction to the product' do
        put path, params: atts.to_json, headers: headers(vendor)
        expect(@product.reload.sales.size).to eq 1
      end
    end
  end
end
