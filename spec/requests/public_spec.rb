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

  describe "GET /my_parcels" do
    it "returns http success" do
      get "/public/my_parcels"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /purchases" do
    it "returns http success" do
      get "/public/purchases"
      expect(response).to have_http_status(:success)
    end
  end

end
