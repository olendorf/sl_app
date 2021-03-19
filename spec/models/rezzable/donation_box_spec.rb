# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::DonationBox, type: :model do
  it { should respond_to :abstract_web_object }

  let(:user) { FactoryBot.create :active_user }
  let(:donation_box) { FactoryBot.create :donation_box, user_id: user.id }
  let(:target) { FactoryBot.create :avatar }

  describe '#last_donation' do
    before(:each) do
      donation_box.transactions << FactoryBot.build(:transaction, created_at: 3.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, 
                                                        created_at: 1.month.ago,
                                                        target_key: target.avatar_key,
                                                        target_name: target.avatar_name,
                                                        amount: 200
                                                    )
      donation_box.transactions << FactoryBot.build(:transaction, created_at: 2.months.ago)
    end
    it 'should return the most recent donation' do

      expect(donation_box.last_donation['created_at']).to be_within(5.seconds).of(1.month.ago)
    end
    
    it 'should return the correct data' do 
      expect(donation_box.last_donation).to include(
          'target_name' => target.avatar_name,
          'target_key' => target.avatar_key,
          'amount' => 200
        )
      
    end
    
    it 'should return nil values when there is no transactions' do 
      empty_box = FactoryBot.create(:donation_box)
      expect(empty_box.last_donation).to include(
          'target_name' => nil,
          'target_key' => nil,
          'amount' => nil,
          'created_at' => nil
        )
    end
  end

  describe '#total_donations' do
    it 'should return the correct value' do
      donation_box.transactions << FactoryBot.build(:transaction, amount: 50,
                                                                  target_name: 'foo',
                                                                  target_key: 'bar',
                                                                  created_at: 3.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 100,
                                                                  target_name: 'foo',
                                                                  target_key: 'bar',
                                                                  created_at: 2.month.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 200,
                                                                  target_name: 'foo',
                                                                  target_key: 'bar',
                                                                  created_at: 1.months.ago)

      expect(donation_box.total_donations).to eq 350
    end
  end

  describe '#largest_donation' do
    it 'should return the largest donation' do
      # target = FactoryBot.create(:avatar)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target.avatar_name,
                                                    target_key: target.avatar_key,
                                                    amount: 50,
                                                    created_at: 3.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 100,
                                                                  created_at: 2.month.ago)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target.avatar_name,
                                                    target_key: target.avatar_key,
                                                    amount: 100,
                                                    created_at: 1.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 200,
                                                                  created_at: 3.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target.avatar_name,
                                                    target_key: target.avatar_key,
                                                    amount: 300,
                                                    created_at: 1.months.ago)
      expect(donation_box.largest_donation).to include(
          'target_name' => target.avatar_name,
          'target_key' => target.avatar_key,
          'amount' => 300
      )
    end
    
    context 'equal sized donations' do 
      it 'should return the most recent' do 
        # target = FactoryBot.create(:avatar)
        donation_box.transactions << FactoryBot.build(:transaction,
                                                      target_name: target.avatar_name,
                                                      target_key: target.avatar_key,
                                                      amount: 50,
                                                      created_at: 3.months.ago)
        donation_box.transactions << FactoryBot.build(:transaction, amount: 100,
                                                                    created_at: 2.month.ago)
        donation_box.transactions << FactoryBot.build(:transaction,
                                                      target_name: target.avatar_name,
                                                      target_key: target.avatar_key,
                                                      amount: 100,
                                                      created_at: 1.months.ago)
        donation_box.transactions << FactoryBot.build(:transaction, amount: 300,
                                                                    created_at: 3.months.ago)
        donation_box.transactions << FactoryBot.build(:transaction,
                                                      target_name: target.avatar_name,
                                                      target_key: target.avatar_key,
                                                      amount: 300,
                                                      created_at: 1.months.ago)
  
         expect(donation_box.largest_donation).to include(
          'target_name' => target.avatar_name,
          'target_key' => target.avatar_key,
          'amount' => 300
        )
      end
    end
      
    context 'no donations' do 
      it 'should return nil values' do 
  
        expect(donation_box.largest_donation).to include(
          'target_name' => nil,
          'target_key' => nil,
          'amount' => nil,
          'created_at' => nil
        )
      end
    end
  end

  describe '#biggest_donor' do
    it 'should return the correct data' do
      target = FactoryBot.build(:avatar)
      target_two = FactoryBot.build(:avatar)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target.avatar_name,
                                                    target_key: target.avatar_key,
                                                    amount: 50,
                                                    created_at: 3.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 100,
                                                                  created_at: 2.month.ago)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target.avatar_name,
                                                    target_key: target.avatar_key,
                                                    amount: 100,
                                                    created_at: 1.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target_two.avatar_name,
                                                    target_key: target_two.avatar_key,
                                                    amount: 100,
                                                    created_at: 1.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target_two.avatar_name,
                                                    target_key: target_two.avatar_key,
                                                    amount: 100,
                                                    created_at: 1.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction, amount: 200,
                                                                  created_at: 1.months.ago)
      donation_box.transactions << FactoryBot.build(:transaction,
                                                    target_name: target.avatar_name,
                                                    target_key: target.avatar_key,
                                                    amount: 200,
                                                    created_at: 1.months.ago)

      expect(donation_box.biggest_donor).to include(
        avatar_key: target.avatar_key,
        avatar_name: target.avatar_name,
        amount: 350
      )
    end
    
    context 'no donations' do 
      it 'should return nil values' do 
        expect(donation_box.biggest_donor).to include(
          avatar_key: nil,
          avatar_name: nil,
          amount: nil
        )
      end
    end
  end
end
