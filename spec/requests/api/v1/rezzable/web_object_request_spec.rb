require 'rails_helper'

RSpec.describe "Api::V1::Rezzable::WebObjects", type: :request do
  let(:owner) { FactoryBot.create :owner }
  
  describe 'creating a web object' do 
    let(:path) { api_rezzable_web_objects_path }
    let(:web_object) { FactoryBot.build :web_object, user_id: owner.id }
    let(:params) { { url: web_object.url } }
  end
end
