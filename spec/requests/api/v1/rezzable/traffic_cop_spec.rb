require 'rails_helper'

RSpec.describe "Api::V1::Rezzable::TrafficCops", type: :request do
  it_behaves_like 'a user object API', :traffic_cop
  
  let(:user) { FactoryBot.create :active_user }
  let(:traffic_cop) { FactoryBot.create :traffic_cop, user_id: user.id }
  
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
  

  

end
