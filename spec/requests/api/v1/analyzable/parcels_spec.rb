# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Analyzable::Parcels', type: :request do
  # describe 'GET /index' do
  #   pending "add some examples (or delete) #{__FILE__}"
  # end

  let(:user) { FactoryBot.create :active_user }
  let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id, region: 'foo' }

  describe 'create' do
    let(:path) { api_analyzable_parcels_path }
    let(:atts) { FactoryBot.attributes_for :parcel }

    it 'should return created status' do
      post path, params: atts.to_json, headers: headers(parcel_box)
      expect(response.status).to eq 201
    end

    it 'should add the parcel to the user' do
      expect {
        post path, params: atts.to_json, headers: headers(parcel_box)
      }.to change(user.parcels, :count).by(1)
    end
  end

  describe 'show' do
    before(:each) do
      @parcel = FactoryBot.create :parcel, parcel_box_id: parcel_box.id, user_id: user.id
    end

    it 'should return ok status' do
      path = api_analyzable_parcel_path(@parcel)
      get path, headers: headers(parcel_box)
      expect(response.status).to eq 200
    end

    it 'should return the correct data' do
      path = api_analyzable_parcel_path(@parcel)
      get path, headers: headers(parcel_box)
      expect(JSON.parse(response.body)['data']).to include(
        'parcel_name', 'description', 'owner_key', 'owner_name', 'area',
        'parcel_key', 'weekly_tier', 'purchase_price', 'region', 'expiration_date'
      )
    end
  end

  describe 'update' do
    before(:each) do
      @parcel = FactoryBot.create :parcel, parcel_box_id: parcel_box.id, user_id: user.id
    end
    let(:path ) { api_analyzable_parcel_path(@parcel) }

    it 'should return ok status' do
      # path = api_analyzable_parcel_path(@parcel)
      atts = { weekly_tier: 101, purchase_price: 1 }
      put path, params: atts.to_json, headers: headers(parcel_box)
      expect(response.status).to eq 200
    end

    it 'should update the parcel info' do
      # path = api_analyzable_parcel_path(@parcel)
      atts = { weekly_tier: 101, purchase_price: 1 }
      put path, params: atts.to_json, headers: headers(parcel_box)
      expect(@parcel.reload.weekly_tier).to eq 101
    end
    
  end
  
  describe 'tier station requests' do 
    let(:tier_station) { FactoryBot.create :tier_station, user_id: user.id }
    let(:renter) { FactoryBot.create :avatar }
    
    before(:each) do 
      3.times do
        user.parcels << FactoryBot.create(:parcel)
      end
      5.times do |i|
        user.parcels << FactoryBot.create(:parcel, parcel_name: "parcel #{i}", region: 'foo')
      end
      2.times do |i|
        user.parcels << FactoryBot.create(:parcel,
                                parcel_name: "#{renter.avatar_name}'s parcel #{i}",
                                owner_name: renter.avatar_name,
                                owner_key: renter.avatar_key,
                                expiration_date: 1.week.from_now
        )
      end
      
      
      
      
    end
    
    describe 'getting renters parcels' do
      let(:atts) {
          {scope: 'renter',
          owner_key: renter.avatar_key}
      }
      let(:path) {api_analyzable_parcels_path}
      it 'should return ok status' do 
        get path, params: atts.to_json, headers: headers(tier_station)
        expect(response.status).to eq 200
      end
      
      it 'should return the renters parcles' do 
        get path, params: atts, headers: headers(tier_station)
        expect(JSON.parse(response.body)['data']['parcels'].size).to eq 2
      end
    end
    
    describe 'user makes a tier payment' do 
      let(:owner) { FactoryBot.create :owner }
      let(:terminal) { FactoryBot.create :terminal, user_id: owner.id }
      let(:parcel) { user.parcels.find_by_parcel_name("#{renter.avatar_name}'s parcel 1")}
      let(:path) { api_analyzable_parcel_path(parcel) }
      let(:atts) { 
        {tier_payment: {
          amount: parcel.weekly_tier * 3,
          object_key: terminal.object_key
          } 
        }
      }
      
      it 'should return ok status' do 
        put path, params: atts.to_json, headers: headers(tier_station)
        expect(response.status).to eq 200
      end
      
      it 'should update the expiration_date' do 
        put path, params: atts.to_json, headers: headers(tier_station)
        expect(parcel.reload.expiration_date).to be_within(1.minute).of(4.weeks.from_now)
      end
      
      it 'should add the transaction' do 
        put path, params: atts.to_json, headers: headers(tier_station)
        expect(user.reload.transactions.size).to eq 1
      end
    end

  end
  


  describe 'index' do
    let(:path) { api_analyzable_parcels_path }
    before(:each) do
      24.times do |i|
        user.parcels << FactoryBot.build(:parcel, parcel_name: "parcel #{i}", region: 'foo')
      end
      3.times do |_i|
        user.parcels << FactoryBot.build(:parcel)
      end
    end

    context 'no page sent' do
      it 'returns ok status' do
        get path, headers: headers(parcel_box)
        expect(response.status).to eq 200
      end

      it 'returns the first page' do
        get path, headers: headers(parcel_box)
        expect(JSON.parse(response.body)['data']['parcels'].size).to eq 9
      end

      it 'should return the correct data' do
        get path, headers: headers(parcel_box)
        expect(JSON.parse(response.body)['data']['parcels'].first['parcel_name']).to eq 'parcel 0'
      end
    end

    context '1st page' do
      it 'returns ok status' do
        get path, params: { parcel_page: 1 }, headers: headers(parcel_box)
        expect(response.status).to eq 200
      end

      it 'returns the first page' do
        get path, params: { parcel_page: 1 }, headers: headers(parcel_box)
        expect(JSON.parse(response.body)['data']['parcels'].size).to eq 9
      end

      # it 'should return the correct data' do
      #   get path, params: { parcel_page: 1 }, headers: headers(parcel_box)
      #   data = JSON.parse(response.body)['data']['parcels'].collect do |d|
      #     d['parcel_name']
      #   end
      #   # expect(JSON.parse(response.body)['data']['parcels'].collect).to eq 'parcel 0'
      #   expect(data).to include(
      #     'parcel 0', 'parcel 1', 'parcel 2', 'parcel 3', 'parcel 4',
      #     'parcel 5', 'parcel 6', 'parcel 7', 'parcel 8'
      #     )
        
      # end
    end

    context '2nd page' do
      it 'returns ok status' do
        get path, params: { parcel_page: 2 }, headers: headers(parcel_box)
        expect(response.status).to eq 200
      end

      it 'returns the first page' do
        get path, params: { parcel_page: 2 }, headers: headers(parcel_box)
        expect(JSON.parse(response.body)['data']['parcels'].size).to eq 9
      end

      it 'should return the correct data' do
        get path, params: { parcel_page: 2 }, headers: headers(parcel_box)
        expected = []
        9.times do |i|
          expected << "parcel #{i + 9}"
        end
        data = JSON.parse(response.body)['data']['parcels'].collect do |d|
          d['parcel_name']
        end
        expect(data).to include(*expected)
      end
    end

    context 'last page' do
      it 'returns ok status' do
        get path, params: { parcel_page: 3 }, headers: headers(parcel_box)
        expect(response.status).to eq 200
      end

      it 'returns the first page' do
        get path, params: { parcel_page: 3 }, headers: headers(parcel_box)
        expect(JSON.parse(response.body)['data']['parcels'].size).to eq 6
      end

      it 'should return the correct data' do
        get path, params: { parcel_page: 3 }, headers: headers(parcel_box)
        expect(JSON.parse(response.body)['data']['parcels'].first['parcel_name']).to eq 'parcel 18'
      end
    end
  end
end
