require 'rails_helper'

RSpec.describe Rezzable::DonationBox, type: :model do
  it { should respond_to :abstract_web_object }
  
  let(:user) { FactoryBot.create :active_user }
  let(:donation_box) { FactoryBot.create :donation_box, user_id: user.id }
  
  describe '#last_donation' do 
    
    it 'should return the most recent donation' do
      donation_box.transactions << FactoryBot.build(:transaction, created_at: 3.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, created_at: 1.month.ago)
      donation_box.transactions << FactoryBot.build(:transaction, created_at: 2.months.ago)
      
      expect(donation_box.last_donation.created_at).to be_within(5.seconds).of(1.month.ago)
    end
    
    
  end
  
  describe 'total donations' do 
    it 'should return the correct value' do 
      donation_box.transactions << FactoryBot.build(:transaction, amount: 50, created_at: 3.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 100, created_at: 2.month.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 200, created_at: 1.months.ago)
      
      expect(donation_box.reload.total_donations).to eq 350
    end
  end
end
