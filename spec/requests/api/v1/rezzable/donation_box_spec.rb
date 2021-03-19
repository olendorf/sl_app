require 'rails_helper'

RSpec.describe "Api::V1::Rezzable::DonationBoxes", type: :request do
  it_behaves_like 'a user object API', :donation_box
  
  let(:user) { FactoryBot.create :active_user }
  let(:donation_box) { FactoryBot.create :donation_box, user_id: user.id }
  
  describe 'response data' do 
    it 'should return the correct data fields' do 
      # path = api_rezzable_donation_box_path(donation_box)
      get api_rezzable_donation_box_path(donation_box), headers: headers(donation_box)
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
  
  describe 'donations' do 
    let(:path) { api_rezzable_donation_box_path(donation_box) }
    let(:target) { FactoryBot.create :avatar }

    
    context 'valid params' do 
      let(:atts) {
        {
          transactions_attributes: [{
              amount: 100,
              target_name: target.avatar_name,
              target_key: target.avatar_key
            }]
        }
      }
      
      it 'should return ok status' do 
        put path, params: atts.to_json, headers: headers(donation_box)
        
        expect(response.status).to eq 200
      end
      
      it 'should add the transcaction to the donation_box' do 
        expect{
          put path, params: atts.to_json, headers: headers(donation_box)
        }.to change(donation_box.transactions, :count).by(1)
      end
      
      it 'the transaction should have the correct data' do 
        put path, params: atts.to_json, headers: headers(donation_box)
        expect(donation_box.transactions.last.attributes).to include(
          'amount' => 100,
          'target_name' => target.avatar_name,
          'target_key' => target.avatar_key,
          'category' => 'donation',
          'source_key' => donation_box.object_key,
          'source_name' => donation_box.object_name,
          'source_type' => 'donation box',
          'description' => "Donation from #{target.avatar_name}."
        )
      end
      
      it 'should add the transaction to the user' do 
        expect{
          put path, params: atts.to_json, headers: headers(donation_box)
        }.to change(user.transactions, :count).by(1)
      end
      
      it 'should say the response' do 
        put path, params: atts.to_json, headers: headers(donation_box)
        expect(JSON.parse(response.body)['message']).to eq 'Thank you'
      end

    end
    
    
    context 'invalid params' do 
      let(:atts) {
        {
          transactions_attributes: [{
              amount: 100,
              target_name: target.avatar_name
            }]
        }
      }
      
      it 'should return bad request status' do 
        put path, params: atts.to_json, headers: headers(donation_box)
        expect(response.status).to eq 422
      end
      
      it 'should return a useful message' do 
        put path, params: atts.to_json, headers: headers(donation_box)
        expect(
          JSON.parse(response.body)['message']
          ).to eq "Validation failed: Transactions target key can't be blank"
      end
      
      it 'should not create a transaction' do 
        expect{
          put path, params: atts.to_json, headers: headers(donation_box)
        }.to_not change(Analyzable::Transaction, :count)
      end
    end
  end
  
  describe 'changing settings in world' do 
    let(:path) { api_rezzable_donation_box_path(donation_box) }
    
    context 'valid params' do 
      let(:atts) { {show_last_donation: true, goal: 200} }
      it 'should return ok status' do 
        put path, params: atts.to_json, headers: headers(donation_box)
        expect(response.status).to eq 200
      end
    end
    
  end
    
end
