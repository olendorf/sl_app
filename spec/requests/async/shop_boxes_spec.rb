# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Async::ShopBoxes', type: :request do
  describe 'GET' do
    
    before(:all) do
      @user = FactoryBot.create :active_user 
      @server = FactoryBot.create :server, user_id: @user.id
      uri_regex =  %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
         auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
      stub_request(:post, uri_regex)
      server = FactoryBot.create(:server)
      @user.web_objects << server
      2.times do
        shop = FactoryBot.build(
          :shop_rental_box, 
          expiration_date: 1.week.from_now
        )
        @user.web_objects << shop
      end
      
      3.times do
        shop = FactoryBot.build(
          :shop_rental_box, 
          expiration_date: 1.week.from_now
        )
        @user.web_objects << shop
        4.times do |i|
          shop.update(rent_payment: shop.weekly_rent)
        end
      end
      
      4.times do 
        shop = FactoryBot.build(
          :shop_rental_box, 
          expiration_date: 1.week.from_now
        )
        @user.web_objects << shop
        3.times do |i|
          shop.update(rent_payment: shop.weekly_rent)
        end
        shop.evict_renter(@server, 'for_rent')
      end
    end
  

    before(:each) { sign_in @user }
    
    let(:path) { async_shop_rentals_path }
    
    describe 'asking for status data' do 
      it 'should return OK status' do 
        get path, params: {chart: 'shop_rental_status_chart'}
        expect(response.status).to eq 200
      end
    end

   
  end
end
