# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopData do
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
  
  describe '#shop_status_barchart' do 
    it 'should return the data' do 
      data = ShopData.shop_status_barchart(user)
      expect(data).to include :regions, :data
    end
  end
  
  describe '#shop_renters' do 
    it 'should return the data' do 
      expect(ShopData.shop_renters(user).size).to eq 3
    end
  end
  
  describe '#shop_status_timeline' do 
    it 'should return the data' do 
      data = ShopData.shop_status_timeline(user)
      expect(data[:dates].size).to eq 4
      expect(data[:data][0][:data].size).to eq 4
    end
  end
  
  describe '#shop_status_ratio_timeline' do 
    it 'should return the data' do 
      data = ShopData.shop_status_ratio_timeline(user)
      expect(data[:dates].size).to eq 4
      expect(data[:data][0][:data].size).to eq 4
    end
  end  
  
  describe '#region_revenue_bar_chart' do 
    it 'should return the data' do 
      data = ShopData.region_revenue_bar_chart(user)
      expect(data[:regions].size).to eq 7
      expect(data[:data].size).to eq 7
    end
  end
  
  describe '#rental_income_timeline' do 
    it 'should return the data' do 
      data = ShopData.rental_income_timeline(user)
      expect(data[:dates].size).to eq 1
      expect(data[:data].size).to eq 7
    end
  end
  
  
  
  
end