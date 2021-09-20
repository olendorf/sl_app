# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Analyzable::Parcels', type: :request do
  # describe 'GET /index' do
  #   pending "add some examples (or delete) #{__FILE__}"
  # end

  let(:user) { FactoryBot.create :active_user }
  let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id, region: 'foo' }

  describe 'show' do
    before(:each) do
      @parcel = FactoryBot.create :parcel, user_id: user.id
      @parcel.parcel_box = parcel_box
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

  describe 'parcel life cycle requests' do
    describe 'setting out a parcel box' do
      context 'on a new parcel' do
        let(:path) { api_analyzable_parcels_path }
        let(:atts) {
          {
            parcel_name: 'parcel one',
            description: 'test parcel',
            area: 8912,
            parcel_key: SecureRandom.uuid,
            weekly_tier: 3000,
            purchase_price: 2000,
            region: 'my nice region'
          }
        }
        it 'should create a new parcel' do
          post path, params: atts.to_json, headers: headers(parcel_box)
          expect(user.parcels.size).to eq 1
        end
        it 'should set the parcel for sale' do
          post path, params: atts.to_json, headers: headers(parcel_box)
          expect(user.parcels.last.states.last.state).to eq 'for_sale'
        end
      end

      context 'on an existing parcel' do
        let(:parcel) { FactoryBot.create :parcel, user_id: user.id }
        let(:atts) { { parcel_box_key: parcel_box.object_key } }
        let(:path) { api_analyzable_parcel_path(parcel) }
        before(:each) do
          parcel.states << FactoryBot.create(
            :state, state: 'open', created_at: 1.day.ago, user_id: user.id
          )
        end

        it 'should not create a parcel' do
          put path, params: atts.to_json, headers: headers(parcel_box)
          expect(user.parcels.size).to eq 1
        end
        it 'should set the parcel for sale' do
          put path, params: atts.to_json, headers: headers(parcel_box)
          expect(user.parcels.last.states.last.state).to eq 'for_sale'
        end
        it 'should update the previous states duration' do
          put path, params: atts.to_json, headers: headers(parcel_box)
          expect(user.parcels.last.states.second.reload.duration).to be_within(1.second).of(1.day)
        end
      end
    end
    context 'someone buys parcel' do
      let(:parcel) { FactoryBot.create :parcel, user_id: user.id }
      let(:parcel_box) {
        FactoryBot.create :parcel_box, user_id: user.id,
                                       parcel_id: parcel.id
      }
      let(:avatar) { FactoryBot.create :avatar }
      let(:atts) { { owner_key: avatar.avatar_key, owner_name: avatar.avatar_name } }
      let(:path) { api_analyzable_parcel_path(parcel) }
      before(:each) do
        parcel.states << FactoryBot.create(:state, state: 'for_sale')
      end

      it 'should add a state to the parcel' do
        put path, params: atts.to_json, headers: headers(parcel_box)
        expect(parcel.states.size).to eq 3
      end

      it 'should set the state to occupied' do
        put path, params: atts.to_json, headers: headers(parcel_box)
        expect(parcel.states.last.state).to eq 'occupied'
      end

      it 'should remove the parcel_box' do
        put path, params: atts.to_json, headers: headers(parcel_box)
        expect(parcel.parcel_box).to be_nil
      end
    end

    context 'user pays tier' do
      let(:tier_station) { FactoryBot.create :tier_station, user_id: user.id }
      let(:parcel) {
        FactoryBot.create :parcel, user_id: user.id,
                                   expiration_date: 1.week.from_now,
                                   owner_key: avatar.avatar_key,
                                   owner_name: avatar.avatar_name
      }
      let(:avatar) { FactoryBot.create :avatar }
      let(:atts) { { tier_payment: 3 * parcel.weekly_tier } }
      let(:path) { api_analyzable_parcel_path(parcel) }
      before(:each) do
        parcel.states << FactoryBot.create(:state, state: 'occupied')
      end

      it 'should return ok status' do
        put path, params: atts.to_json, headers: headers(tier_station)
        expect(response.status).to eq 200
      end

      it 'should update the expiration_date' do
        put path, params: atts.to_json, headers: headers(tier_station)
        expect(parcel.reload.expiration_date).to be_within(10.second).of(4.weeks.from_now)
      end

      it 'should add a transaction to the user' do
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
        expect(JSON.parse(response.body)['data']['parcels']
                        .first['parcel_name']).to include('parcel 0')
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
    end
  end
end
