# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should respond_to :avatar_name }
  it { should respond_to :avatar_key }

  it { should define_enum_for(:role).with_values(%i[user prime admin owner]) }

  let(:user)  { FactoryBot.create :active_user }
  let(:prime) { FactoryBot.create :prime }
  let(:admin) { FactoryBot.build :admin }
  let(:owner) { FactoryBot.create :owner }

  it { should have_many(:web_objects).class_name('AbstractWebObject').dependent(:destroy) }
  it {
    should have_many(
      :transactions
    ).class_name(
      'Analyzable::Transaction'
    ).dependent(:destroy)
  }

  describe :email_changed? do
    it 'should be falsey' do
      expect(user.email_changed?).to be_falsey
    end
  end

  describe :balance do
    it 'should be zero when the user has no transactions' do
      expect(user.balance).to eq 0
    end

    it 'should return the current balance if teh user has transactions' do
      user.transactions << FactoryBot.build(:transaction, amount: 7)
      user.transactions << FactoryBot.build(:transaction, amount: 15)
      user.transactions << FactoryBot.build(:transaction, amount: 31)
      expect(user.balance).to eq 53
    end
  end

  describe 'can be' do
    User.roles.each do |role, _value|
      it { should respond_to "can_be_#{role}?".to_sym }
    end
    it 'should properly test can_be_<role>?' do
      expect(admin.can_be_owner?).to be_falsey
      expect(admin.can_be_user?).to be_truthy
      expect(owner.can_be_user?).to be_truthy
      expect(user.admin?).to be_falsey
      expect(user.can_be_user?).to be_truthy
      expect(prime.can_be_user?).to be_truthy
      expect(prime.can_be_prime?).to be_truthy
      expect(prime.can_be_admin?).to be_falsey
    end
  end

  describe 'is_active?' do
    it 'should return true for owners' do
      owner.expiration_date = 1.month.ago
      expect(owner.active?).to be_truthy
    end

    it 'should rturn true for active up-to-date users' do
      user.expiration_date = 1.month.from_now
      user.account_level = 1
      expect(user.active?).to be_truthy
    end

    it 'should return false for past due users' do
      user.expiration_date = 1.month.ago
      user.account_level = 1
      expect(user.active?).to be_falsey
    end

    it 'should return false for account level zero' do
      user.expiration_date = 1.month.from_now
      user.account_level = 0
      expect(user.active?).to be_falsey
    end
  end
end
