# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Async::Rentals', type: :request do
  describe 'index' do
    before(:all) do
      @user = FactoryBot.create :active_user
      parcel_box = FactoryBot.create(:parcel_box, user_id: @user.id)
      @user.parcels << FactoryBot.create(:parcel, requesting_object: parcel_box)
      2.times do
        parcel_box = FactoryBot.create(:parcel_box, user_id: @user.id)
        @user.parcels << FactoryBot.create(:parcel, requesting_object: parcel_box)
        avatar = FactoryBot.build(:avatar)
        @user.parcels.last.update(renter_key: avatar.avatar_key, renter_name: avatar.avatar_name)
        @user.parcels.last.update(renter_key: nil, renter_name: nil)
      end

      3.times do
        parcel_box = FactoryBot.create(:parcel_box, user_id: @user.id)
        @user.parcels << FactoryBot.create(:parcel, requesting_object: parcel_box)
        avatar = FactoryBot.build(:avatar)
        @user.parcels.last.update(renter_key: avatar.avatar_key, renter_name: avatar.avatar_name)
      end
    end

    let(:path) { async_rentals_path }

    before(:each) { sign_in @user }

    context 'asking for parcel state treemap data' do
      it 'should return ok status' do
        get path, params: { chart: 'parcel_status_treemap' }
        expect(response.status).to eq 200
      end

      it 'should return the data' do
        get path, params: { chart: 'parcel_status_treemap' }
        expect(JSON.parse(response.body).size).to eq 21
      end
    end

    context 'asking for parcel state timeline' do
      it 'should return ok status' do
        get path, params: { chart: 'parcel_status_timeline' }
        expect(response.status).to eq 200
      end

      it 'should return the data' do
        get path, params: { chart: 'parcel_status_timeline' }
        expect(JSON.parse(response.body)['data'].size).to eq 3
      end
    end

    context 'asking for rental income timeline' do
      it 'should return ok status' do
        get path, params: { chart: 'rental_income_timeline' }
        expect(response.status).to eq 200
      end

      it 'should return the data' do
        get path, params: { chart: 'rental_income_timeline' }
        expect(JSON.parse(response.body)['data'].size).to eq 6
      end
    end

    context 'asking for region revenue barchart' do
      it 'should return ok status' do
        get path, params: { chart: 'region_revenue_bar_chart' }
        expect(response.status).to eq 200
      end

      it 'should return the data' do
        get path, params: { chart: 'region_revenue_bar_chart' }
        expect(JSON.parse(response.body)['data'].size).to eq 5
      end
    end
  end

  # describe 'GET' do
  #   before(:all) do
  #     @user = FactoryBot.create :active_user
  #     @avatars = FactoryBot.create_list(:avatar, 20)
  #     @server = FactoryBot.create(:server, user_id: @user.id)
  #     3.times do |i|
  #       inventory = FactoryBot.create(:inventory,
  #                                     user_id: @user.id,
  #                                     server_id: @server.id,
  #                                     inventory_name: "inventory #{i}",
  #                                     revenue: 300,
  #                                     price: 100)

  #       vendor = FactoryBot.create(:vendor,
  #                                 inventory_name: inventory.inventory_name,
  #                                 server_id: @server.id,
  #                                 user_id: @user.id)
  #       product = FactoryBot.create(:product,
  #                                   user_id: @user.id,
  #                                   product_name: "product #{i}")
  #       product.product_links << FactoryBot.build(:product_link,
  #                                                 user_id: @user.id,
  #                                                 link_name: inventory.inventory_name)

  #       3.times do
  #         avatar = @avatars.sample
  #         FactoryBot.create(:sale,
  #                           amount: inventory.price.to_i,
  #                           user_id: @user.id,
  #                           target_key: avatar.avatar_key,
  #                           target_name: avatar.avatar_name,
  #                           transactable_id: vendor.id,
  #                           transactable_type: 'Rezzable::Vendor',
  #                           inventory_id: inventory.id,
  #                           product_id: product.id)
  #       end
  #     end
  #   end

  #   let(:path) { async_sales_path }

  #   before(:each) { sign_in @user }

  #   context 'asking for data from a single vendor' do
  #     describe 'sales timeline data' do
  #       it 'should return OK status' do
  #         get path, params: { chart: 'vendor_sales_timeline', ids: [@user.vendors.first.id] }
  #         expect(response.status).to eq 200
  #       end

  #       it 'should return the data' do
  #         get path, params: { chart: 'vendor_sales_timeline', ids: [@user.vendors.first.id] }
  #         expect(JSON.parse(response.body)['counts']).to eq [0, 0, 0, 3]
  #       end
  #     end
  #   end

  #   context 'asking for data from a single inventory' do
  #     describe 'inventory sales timeline data' do
  #       it 'should return OK status' do
  #         get path,
  #             params: { chart: 'inventory_sales_timeline', ids: [@user.inventories.first.id] }
  #         expect(response.status).to eq 200
  #       end

  #       it 'should return the data' do
  #         get path,
  #             params: { chart: 'inventory_sales_timeline', ids: [@user.inventories.first.id] }
  #         expect(JSON.parse(response.body)['counts']).to eq [0, 0, 0, 3]
  #       end
  #     end
  #   end

  #   context 'asking for data from a single product' do
  #     describe 'product sales timeline data' do
  #       it 'should return OK status' do
  #         get path, params: { chart: 'product_sales_timeline', ids: [@user.products.first.id] }
  #         expect(response.status).to eq 200
  #       end

  #       it 'should return the data' do
  #         get path, params: { chart: 'product_sales_timeline', ids: [@user.products.first.id] }
  #         expect(JSON.parse(response.body)['counts']).to eq [0, 0, 0, 3]
  #       end
  #     end
  #   end

  #   describe 'asking for product revenue timeline data' do
  #     it 'should return ok status' do
  #       get path, params: { chart: 'sales_by_product_revenue_timeline' }
  #       expect(response.status).to eq 200
  #     end

  #     it 'should return the data' do
  #       get path, params: { chart: 'sales_by_product_revenue_timeline' }
  #       expect(JSON.parse(response.body).with_indifferent_access).to eq(
  #         { 'colors' => ['#c7e10f', '#ac70f3', '#dcfe90'],
  #           'data' => [{ 'data' => [0, 300], 'name' => 'product 2' },
  #                     { 'data' => [0, 300], 'name' => 'product 1' },
  #                     { 'data' => [0, 300], 'name' => 'product 0' }],
  #           'dates' => [1.month.ago.strftime('%B %Y'), Time.current.strftime('%B %Y')] }
  #       )
  #     end
  #   end

  #   describe 'asking for product items timeline data' do
  #     it 'should return ok status' do
  #       get path, params: { chart: 'sales_by_product_items_timeline' }
  #       expect(response.status).to eq 200
  #     end

  #     it 'should return the data' do
  #       get path, params: { chart: 'sales_by_product_items_timeline' }
  #       expect(JSON.parse(response.body).with_indifferent_access).to eq(
  #         { 'colors' => ['#c7e10f', '#ac70f3', '#dcfe90'],
  #           'data' => [{ 'data' => [0, 3], 'name' => 'product 2' },
  #                     { 'data' => [0, 3], 'name' => 'product 1' },
  #                     { 'data' => [0, 3], 'name' => 'product 0' }],
  #           'dates' => [1.month.ago.strftime('%B %Y'), Time.current.strftime('%B %Y')] }
  #       )
  #     end
  #   end

  #   describe 'asking for inventory revenue timeline data' do
  #     it 'should return ok status' do
  #       get path, params: { chart: 'sales_by_inventory_revenue_timeline' }
  #       expect(response.status).to eq 200
  #     end

  #     it 'should return the data' do
  #       get path, params: { chart: 'sales_by_inventory_revenue_timeline' }
  #       expect(JSON.parse(response.body).with_indifferent_access).to eq(
  #         { 'colors' => ['#255828', '#fc5fc2', '#368986'],
  #           'data' => [{ 'data' => [0, 300], 'name' => 'inventory 2' },
  #                     { 'data' => [0, 300], 'name' => 'inventory 1' },
  #                     { 'data' => [0, 300], 'name' => 'inventory 0' }],
  #           'dates' => [1.month.ago.strftime('%B %Y'), Time.current.strftime('%B %Y')] }
  #       )
  #     end
  #   end

  #   describe 'asking for inventory items timeline data' do
  #     it 'should return ok status' do
  #       get path, params: { chart: 'sales_by_product_items_timeline' }
  #       expect(response.status).to eq 200
  #     end

  #     it 'should return the data' do
  #       get path, params: { chart: 'sales_by_inventory_items_timeline' }
  #       expect(JSON.parse(response.body).with_indifferent_access).to eq(
  #         { 'colors' => ['#255828', '#fc5fc2', '#368986'],
  #           'data' => [{ 'data' => [0, 3], 'name' => 'inventory 2' },
  #                     { 'data' => [0, 3], 'name' => 'inventory 1' },
  #                     { 'data' => [0, 3], 'name' => 'inventory 0' }],
  #           'dates' => [1.month.ago.strftime('%B %Y'), Time.current.strftime('%B %Y')] }
  #       )
  #     end
  #   end
  # end
end
