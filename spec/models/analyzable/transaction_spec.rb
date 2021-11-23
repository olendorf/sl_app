# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Transaction, type: :model do
  let(:active_user) { FactoryBot.create :active_user }

  it { should belong_to :user }
  it { should belong_to :transactable }
  it { should belong_to(:session).optional }
  it { should belong_to(:inventory) }
  it { should belong_to(:product) }
  it { should belong_to(:parcel).optional }

  it { should validate_presence_of :target_name }
  it { should validate_presence_of :target_name }
  it { should validate_numericality_of(:amount).only_integer }

  it {
    should define_enum_for(:category).with_values(%i[other account donation tip 
                                                     sale tier rent share
                                                     land_sale])
  }

  describe 'balance' do
    it 'should be THE amount when its the users first transaction' do
      active_user.transactions << FactoryBot.build(:transaction, amount: 42)
      expect(active_user.transactions.last.balance).to eq 42
    end

    it 'should update the balance as transactions are added' do
      active_user.transactions << FactoryBot.build(:transaction, amount: 42)
      active_user.transactions << FactoryBot.build(:transaction, amount: 150)
      active_user.transactions << FactoryBot.build(:transaction, amount: 100)
      expect(active_user.transactions.last.balance).to eq 292
    end
  end

  describe 'previous balance' do
    it 'should be zero for the first transaction' do
      active_user.transactions << FactoryBot.build(:transaction, amount: 42)
      expect(active_user.transactions.last.previous_balance).to eq 0
    end

    it 'should reflect the balance from the transaction before' do
      active_user.transactions << FactoryBot.build(:transaction, amount: 42)
      active_user.transactions << FactoryBot.build(:transaction, amount: 150)
      active_user.transactions << FactoryBot.build(:transaction, amount: 100)
      expect(active_user.transactions.last.previous_balance).to eq 192
    end
  end
end
