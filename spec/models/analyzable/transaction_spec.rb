# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Transaction, type: :model do
  let(:active_user) { FactoryBot.create :active_user }

  it { should belong_to :user }

  describe 'balance' do
    it 'should be teh amount when its the users first transaction' do
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
end
