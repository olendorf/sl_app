# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::WebObjects', type: :request do 
  let(:user) { FactoryBot.create :active_user }

  let(:web_object) {
      FactoryBot.create :web_object, user_id: user.id
  }
  let(:path) { api_rezzable_web_object_path(web_object.object_key) }
  before(:each) { get path, headers: headers(web_object, 
                              api_key: Settings.default.web_object.api_key) }
  it 'should return OK status' do
    expect(response.status).to eq 200
  end

  it 'should return the data' do
    web_object.reload
    expect(JSON.parse(response.body)['message']).to eq 'Success!'
  end
end
