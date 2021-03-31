require 'rails_helper'

RSpec.describe "Async::Donations", type: :request do
  describe "GET" do
    let(:user) { FactoryBot.create :active_user }
    let(:box_one) { FactoryBot.create :donation_box, user_id: user.id }
    let(:box_two) { FactoryBot.create :donation_box, user_id: user.id }
    before(:each) do 
      target = FactoryBot.build :avatar
      10.times do |i|
        box_one.transactions << FactoryBot.build(:donation, target_name: "target_one_#{i}")
        box_two.transactions << FactoryBot.build(:donation, target_name: "target_two_#{i}")
      end
      box_one.transactions << FactoryBot.build(:donation, 
                                                  target_name: target.avatar_name, 
                                                  target_key: target.avatar_key)
      box_one.transactions << FactoryBot.build(:donation, 
                                                  target_name: target.avatar_name, 
                                                  target_key: target.avatar_key)
      sign_in user
    end
    
    let(:path) { async_donations_path }
    
    context 'asking for single donation histogram data' do 
      it 'should return ok status' do 
        get path, params: {chart: 'donation_histogram'}
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: {chart: 'donation_histogram'}
        expect(JSON.parse(response.body).size).to eq 22
      end
    end
    
    context 'asking for donor amount histogram data' do 
      it 'should return ok status' do 
        get path, params: {chart: 'donor_amount_histogram'}
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: {chart: 'donor_amount_histogram'}
        expect(JSON.parse(response.body).size).to eq 21
      end
    end
  end
end
