# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::TrafficCops', type: :request do
  it_behaves_like 'a user object API', :traffic_cop

  let(:user) { FactoryBot.create :active_user }
  let(:traffic_cop) {
    FactoryBot.create :traffic_cop, user_id: user.id,
                                    first_visit_message: 'foo',
                                    repeat_visit_message: 'bar'
  }

  describe 'adding an allowed avatar.' do
    let(:avatar) { FactoryBot.build :avatar }
    let(:atts) {
      {
        listable_avatars_attributes: [{
          avatar_name: avatar.avatar_name,
          avatar_key: avatar.avatar_key,
          list_name: 'allowed'
        }]
      }
    }
    let(:path) { api_rezzable_traffic_cop_path(traffic_cop) }
    it 'should return ok status' do
      put path, params: atts.to_json, headers: headers(traffic_cop)
      expect(response.status).to eq 200
    end

    it 'should add the avatar' do
      expect {
        put path, params: atts.to_json, headers: headers(traffic_cop)
      }.to change(traffic_cop.allowed_list, :size).by(1)
    end
  end

  describe 'adding an banned avatar.' do
    let(:avatar) { FactoryBot.build :avatar }
    let(:atts) {
      {
        listable_avatars_attributes: [{
          avatar_name: avatar.avatar_name,
          avatar_key: avatar.avatar_key,
          list_name: 'banned'
        }]
      }
    }
    let(:path) { api_rezzable_traffic_cop_path(traffic_cop) }

    it 'should return ok status' do
      put path, params: atts.to_json, headers: headers(traffic_cop)
      expect(response.status).to eq 200
    end

    it 'should add the avatar' do
      expect {
        put path, params: atts.to_json, headers: headers(traffic_cop)
      }.to change(traffic_cop.banned_list, :size).by(1)
    end
  end

  describe 'adding a detection' do
    let(:path) { api_rezzable_traffic_cop_path(traffic_cop) }
    context 'new visitor and new visit' do
      let(:avatar) { FactoryBot.build :avatar }
      let(:atts) {
        {
          detection: {
            avatar_name: 'test',
            avatar_key: 'test',
            position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
              .transform_values { |v| v.round(4) }
          }
        }
      }

      before(:each) { put path, params: atts.to_json, headers: headers(traffic_cop) }

      it 'should return ok status' do
        # put path, params: atts.to_json, headers: headers(traffic_cop)
        expect(response.status).to eq 200
      end

      it 'should add the visit' do
        # put path, params: atts.to_json, headers: headers(traffic_cop)
        expect(traffic_cop.visits.size).to eq 1
      end

      it 'should return the appropriate response' do
        expect(JSON.parse(response.body)['data']['response']).to eq 'foo'
      end
    end

    context 'repeat visitor and new visit' do
      let(:avatar) { FactoryBot.build :avatar }
      let(:atts) {
        {
          detection: {
            avatar_name: 'test',
            avatar_key: 'test',
            position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
              .transform_values { |v| v.round(4) }
          }
        }
      }

      before(:each) do
        traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'test',
                                                       avatar_key: 'test',
                                                       start_time: 5.days.ago,
                                                       stop_time: 4.days.ago,
                                                       duration: 1.day.to_int)
        FactoryBot.create(:detection, visit_id: traffic_cop.visits.last.id)
        put path, params: atts.to_json, headers: headers(traffic_cop)
      end

      it 'should return ok status' do
        # put path, params: atts.to_json, headers: headers(traffic_cop)
        expect(response.status).to eq 200
      end

      it 'should add the visit' do
        # put path, params: atts.to_json, headers: headers(traffic_cop)
        expect(traffic_cop.visits.size).to eq 2
      end

      it 'should return the appropriate response' do
        expect(JSON.parse(response.body)['data']['response']).to eq 'bar'
      end
    end

    context 'visitor is allowed' do
      let(:atts) {
        {
          detection: {
            avatar_name: 'test',
            avatar_key: 'test',
            position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
              .transform_values { |v| v.round(4) }
          }
        }
      }

      before(:each) do
        put path, params: atts.to_json, headers: headers(traffic_cop)
      end

      it 'should return allowed in data' do
        puts response.body
        expect(JSON.parse(response.body)['data']['has_access']).to be_truthy
      end
    end

    context 'visitor is not allowed' do
      let(:atts) {
        {
          detection: {
            avatar_name: 'test',
            avatar_key: 'test',
            position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
              .transform_values { |v| v.round(4) }
          }
        }
      }

      before(:each) do
        traffic_cop.listable_avatars << FactoryBot.build(:banned_avatar, avatar_key: 'test')
        put path, params: atts.to_json, headers: headers(traffic_cop)
      end

      it 'should return allowed in data' do
        puts response.body
        expect(JSON.parse(response.body)['data']['has_access']).to be_falsey
      end
    end
  end
end
