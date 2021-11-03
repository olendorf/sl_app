require 'rails_helper'

RSpec.describe "Publics", type: :request do
  describe "GET /available_parcels" do
    let(:user) { FactoryBot.create :active_user }
    it "returns http success" do
      get "/public/available_parcels", params: {
        avatar_key: user.avatar_key
      }
      expect(response).to have_http_status(:success)
    end
  end
  
  let(:user) { FactoryBot.create :active_user }
  let(:web_object) { FactoryBot.create :server, user_id: user.id }
  
  describe 'public pages with authorization' do 
    context 'valid params sent' do 
      let(:auth_time) { Time.now.to_i }
    
      
      let(:digest) {
        Digest::SHA1.hexdigest(
          auth_time.to_s + web_object.api_key
        )
      }
  
      describe "GET /my_parcels" do
        it "returns http success" do
          get "/public/my_parcels", params: {
            object_key: web_object.object_key,
            auth_digest: digest,
            auth_time: auth_time
          }
          expect(response).to have_http_status(:success)
        end
      end
    
      describe "GET /my_purchases" do
        it "returns http success" do
          get "/public/my_purchases", params: {
            object_key: web_object.object_key,
            auth_digest: digest,
            auth_time: auth_time
          }
          expect(response).to have_http_status(:success)
        end
      end
    end
    
    context 'stale time sent' do 
      let(:auth_time) { 70.seconds.ago.to_i }
    
      
      let(:digest) {
        Digest::SHA1.hexdigest(
          auth_time.to_s + web_object.api_key
        )
      }
  
      describe "GET /my_parcels" do
        it "returns http redirect" do
          get "/public/my_parcels", params: {
            object_key: web_object.object_key,
            auth_digest: digest,
            auth_time: auth_time
          }
          expect(response).to have_http_status(400)
        end
      end
    
      describe "GET /my_purchases" do
        it "returns http redirect" do
          get "/public/my_purchases", params: {
            object_key: web_object.object_key,
            auth_digest: digest,
            auth_time: auth_time
          }
          expect(response).to have_http_status(400)
        end
      end
    end
    
    context 'invalid hash sent' do 
      let(:auth_time) { Time.current.to_i }
    
  
      describe "GET /my_parcels" do
        it "returns http redirect" do
          get "/public/my_parcels", params: {
            object_key: web_object.object_key,
            auth_digest: 'foo',
            auth_time: auth_time
          }
          expect(response).to have_http_status(404)
        end
      end
    
      describe "GET /my_purchases" do
        it "returns http redirect" do
          get "/public/my_purchases", params: {
            object_key: web_object.object_key,
            auth_digest: 'foo',
            auth_time: auth_time
          }
          expect(response).to have_http_status(404)
        end
      end
    end
  end

end
