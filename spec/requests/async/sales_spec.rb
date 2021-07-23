# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Async::Visits', type: :request do
  describe 'GET' do
    before(:all) do 
      @user = FactoryBot.create :active_user
      @avatars = FactoryBot.create_list(:avatar, 20)
      @server = FactoryBot.create(:server, user_id: @user.id)
      3.times do 
        inventory = FactoryBot.create(:inventory,
          user_id: @user.id,
          server_id: @server.id)
         vendor = FactoryBot.create(:vendor,
          inventory_name: inventory.inventory_name,
          server_id: @server.id,
          user_id: @user.id
         )
         product = FactoryBot.create(:product,
          user_id: @user.id
         )
         product.product_links << FactoryBot.build(:product_link,
           user_id: @user.id,
           link_name: inventory.inventory_name
           )
           
        3.times do 
          avatar = @avatars.sample
          FactoryBot.create(:sale, 
            amount: inventory.price.to_i,
            user_id: @user.id,
            target_key: avatar.avatar_key,
            target_name: avatar.avatar_name,
            transactable_id: vendor.id,
            transactable_type: 'Rezzable::Vendor',
            inventory_id: inventory.id,
            product_id: product.id
            )
        end
      end
    end
      
    let(:path) { async_sales_path }
      
    before(:each) { sign_in @user }
      
    context 'asking for data from a single vendor' do 
      describe 'sales timeline data' do 
        it 'should return OK status' do 
          get path, params: { chart: 'vendor_sales_timeline', ids: [@user.vendors.first.id] }
          expect(response.status).to eq 200
        end
        
        it 'should return the data' do
          get path, params: { chart: 'vendor_sales_timeline', ids: [@user.vendors.first.id] } 
          expect(JSON.parse(response.body)['counts']).to eq [0, 0, 0, 3]
        end
      end
    end
  end
end
