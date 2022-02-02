# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Async::Rentals', type: :request do  
  let(:user) { FactoryBot.create :active_user }
  
  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end
  
  
  before(:each) do
    stub_request(:post, uri_regex)
    server = FactoryBot.create(:server)
    user.web_objects << server
    2.times do
      shop = FactoryBot.build(
        :shop_rental_box, 
        expiration_date: 1.week.from_now
      )
      user.web_objects << shop
    end
    
    3.times do
      shop = FactoryBot.build(
        :shop_rental_box, 
        expiration_date: 1.week.from_now
      )
      user.web_objects << shop
      avatar = FactoryBot.build :avatar
      4.times do |i|
        shop.update(
                      rent_payment: shop.weekly_rent, 
                      target_key: avatar.avatar_key, 
                      target_name: avatar.avatar_name
                    )
      end
    end
    
    4.times do 
      shop = FactoryBot.build(
        :shop_rental_box, 
        expiration_date: 1.week.from_now
      )
      user.web_objects << shop
      3.times do |i|
        avatar = FactoryBot.build :avatar
        shop.update(
                      rent_payment: shop.weekly_rent, 
                      target_key: avatar.avatar_key, 
                      target_name: avatar.avatar_name
                    )
      end
      shop.evict_renter(server, 'for_rent')
    end
  end
  
  let(:path) { async_shop_rentals_path }
  before(:each) { sign_in user }
  
  describe 'INDEX' do
    context 'asking for parcel status chart data' do
      it 'should return ok status' do 
        get path, params: { chart: 'shop_rental_status_chart' }
        expect(response.status).to eq 200
      end
    end
    
    context 'asking for status timeline data' do
      it 'should return ok status' do 
        get path, params: { chart: 'shop_status_timeline' }
        expect(response.status).to eq 200
      end
    end
    
    context 'asking for status ratio timeline data' do
      it 'should return ok status' do 
        get path, params: { chart: 'shop_status_ratio_timeline' }
        expect(response.status).to eq 200
      end
    end
    
    context 'asking for region revenue barchart data' do
      it 'should return ok status' do 
        get path, params: { chart: 'region_revenue_bar_chart' }
        expect(response.status).to eq 200
      end
    end
    
    
    context 'asking for income timeline data' do
      it 'should return ok status' do 
        get path, params: { chart: 'rental_income_timeline' }
        expect(response.status).to eq 200
      end
    end
  end
end
