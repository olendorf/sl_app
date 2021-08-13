# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::ParcelBoxes', type: :request do
  it_behaves_like 'a user object API', :parcel_box

  let(:user) { FactoryBot.create :active_user }

  describe 'setting a parcel box out' do
    let(:path) { api_rezzable_parcel_boxes_path }
    let(:parcel_box) { FactoryBot.build :parcel_box, user_id: user.id, region: 'foo' }
    let(:atts) { { url: parcel_box.url } }
    context 'there are no other parcels on the sim' do
      it 'should return ok status ' do
        post path, params: atts.to_json,
                   headers: headers(parcel_box, api_key: Settings.default.web_object.api_key)
        expect(response.status).to eq 201
      end

      it 'should return an empty hash of available parcels' do
        post path, params: atts.to_json,
                   headers: headers(parcel_box, api_key: Settings.default.web_object.api_key)
        expect(JSON.parse(response.body)['data']['open_parcels']).to eq({})
      end
    end

    context 'there are other parcels on the sim' do
      before(:each) do
        3.times do |i|
          FactoryBot.create :parcel, region: 'foo', parcel_name: "parcel #{i}", user_id: user.id
        end
        2.times do |i|
          parcel_box = FactoryBot.create :parcel_box, user_id: user.id, region: 'foo'
          FactoryBot.create :parcel, region: 'foo', parcel_name: "taken #{i}",
                                     parcel_box_id: parcel_box.id, user_id: user.id
        end
      end
      it 'should return ok status ' do
        post path, params: atts.to_json,
                   headers: headers(parcel_box, api_key: Settings.default.web_object.api_key)
        expect(response.status).to eq 201
      end

      it 'should return an empty hash of available parcels' do
        post path, params: atts.to_json,
                   headers: headers(parcel_box, api_key: Settings.default.web_object.api_key)
        expect(JSON.parse(response.body)['data']['open_parcels']).to include(
          'parcel 0', 'parcel 1', 'parcel 2'
        )
      end
    end
  end
end
