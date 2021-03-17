require 'rails_helper'

RSpec.describe "Api::V1::Rezzable::DonationBoxes", type: :request do
  it_behaves_like 'a user object API', :donation_box
  
  let(:user) { FactoryBot.create :active_user }
  let(:donation_box) { FactoryBot.create :donation_box, user_id: user.id }
  
  describe 'response data' do 
    it 'should return the correct data fields' do 
      # path = api_rezzable_donation_box_path(donation_box)
      get api_rezzable_donation_box_path(donation_box), headers: headers(donation_box)
      puts response.body
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['data']).to include(
        'last_donation', 'total_donations', 'largest_donation', 'biggest_donor'
        )
      expect(JSON.parse(response.body)['data']['settings']).to include(
        'show_last_donation', 'show_last_donor', 'show_total', 'show_largest_donation',
        'dead_line', 'goal', 'show_biggest_donor'
        )
    end
  end
    
end
