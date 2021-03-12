# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Analyzable::Inventories', type: :request do
  let(:user) { FactoryBot.create :active_user }
  let(:server) {
    server = FactoryBot.build :server, user_id: user.id
    server.save
    server
  }

  describe 'index' do
    let(:path) { api_analyzable_inventories_path }
    before(:each) do
      24.times do |i|
        server.inventories << FactoryBot.build(:inventory, inventory_name: "inventory_#{i}")
      end
    end
    it 'should return ok status' do
      get path, headers: headers(server)
      expect(response.status).to eq 200
    end

    context '1st page' do
      it 'returns the first page' do
        get path, params: { inventory_page: 1 }, headers: headers(server)
        expect(JSON.parse(response.body)['data']['inventory'].size).to eq 9
      end

      it 'returns the correct data' do
        get path, params: { inventory_page: 1 }, headers: headers(server)

        expect(JSON.parse(response.body)['data']['inventory']).to include(
          *server.inventories.limit(9).map(&:inventory_name)
        )
      end
    end

    context 'no page sent' do
      it 'returns the first page' do
        get path, headers: headers(server)
        expect(JSON.parse(response.body)['data']['inventory'].size).to eq 9
      end

      it 'returns the correct data' do
        get path, headers: headers(server)

        expect(JSON.parse(response.body)['data']['inventory']).to include(
          *server.inventories.limit(9).map(&:inventory_name)
        )
      end
    end

    context 'second page' do
      it 'returns the second page' do
        get path, params: { inventory_page: 2 }, headers: headers(server)
        expect(JSON.parse(response.body)['data']['inventory'].size).to eq 9
      end

      it 'returns the correct data' do
        get path, params: { inventory_page: 2 }, headers: headers(server)

        expect(JSON.parse(response.body)['data']['inventory']).to include(
          *server.inventories.limit(9).offset((2 - 1) * 9).map(&:inventory_name)
        )
      end

      it 'returns the correct metadata' do
        get "#{path}?inventory_page=2", headers: headers(server)
        expect(JSON.parse(response.body)['data']).to include(
          'current_page' => 2,
          'next_page' => 3,
          'prev_page' => 1,
          'total_pages' => 3
        )
      end
    end

    context 'last page' do
      it 'returns the second page' do
        get path, params: { inventory_page: 3 }, headers: headers(server)
        expect(JSON.parse(response.body)['data']['inventory'].size).to eq 6
      end

      it 'returns the correct data' do
        get path, params: { inventory_page: 3 }, headers: headers(server)

        expect(JSON.parse(response.body)['data']['inventory']).to include(
          *server.inventories.limit(9).offset((3 - 1) * 9).map(&:inventory_name)
        )
      end
    end
  end

  describe 'create' do
    let(:path) { api_analyzable_inventories_path }

    context 'inventory does not exist' do
      let(:atts) { FactoryBot.attributes_for :inventory }

      it 'should return created status' do
        post path, params: atts.to_json, headers: headers(server)
        expect(response.status).to eq 201
      end

      it 'should create the inventory' do
        expect {
          post path, params: atts.to_json, headers: headers(server)
        }.to change(server.inventories, :count).by(1)
      end
    end

    # It is not easy to know if the ivnentory exists when
    # server is updted, so need to do this too.
    context 'inventory exists' do
      before(:each) { server.inventories << FactoryBot.build(:inventory) }
      let(:atts) { server.inventories.last.attributes.except(:id, :created_at, :updated_at) }

      it 'should return OK status' do
        atts[:owner_perms] = 32_768
        post path, params: atts.to_json, headers: headers(server)
        expect(response.status).to eq 200
      end

      it 'should not create an inventory' do
        atts[:owner_perms] = 32_768
        expect {
          post path, params: atts.to_json, headers: headers(server)
        }.to_not change(server.inventories, :count)
      end

      it 'should update the inventory' do
        atts[:owner_perms] = 32_768
        post path, params: atts.to_json, headers: headers(server)
        expect(server.inventories.last.owner_perms).to eq 32_768
      end
    end
  end

  describe 'show' do
    before(:each) { server.inventories << FactoryBot.build(:inventory) }
    let(:path) { api_analyzable_inventory_path(server.inventories.last.inventory_name) }

    it 'should return ok status' do
      get path, headers: headers(server)
      expect(response.status).to eq 200
    end

    it 'should return the data' do
      get path, headers: headers(server)
      expect(JSON.parse(response.body)['data']).to include(
        server.inventories.last.attributes.except('id', 'user_id', 'server_id', 'created_at',
                                                  'updated_at')
      )
    end
  end

  describe 'destroy' do
    before(:each) do
      10.times do |i|
        server.inventories << FactoryBot.build(:inventory, inventory_name: "inventory_#{i}")
      end
    end
    context 'one inventory' do
      let(:target) { server.inventories.sample }
      it 'should return 200 status' do
        delete api_analyzable_inventory_path(target.inventory_name), headers: headers(server)
        expect(response.status).to eq 200
      end

      it 'should delete teh object' do
        delete api_analyzable_inventory_path(target.inventory_name), headers: headers(server)
        expect(Analyzable::Inventory.where(id: target.id).size).to eq 0
      end
    end

    context 'all inventory' do
      it 'should return ok status' do
        delete api_analyzable_inventory_path('all'), headers: headers(server)
        expect(server.inventories.all.size).to eq 0
      end
    end
  end
end
