# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should respond_to :avatar_name }
  it { should respond_to :avatar_key }
  it { should respond_to :account_payment }

  it { should validate_numericality_of(:account_level).is_greater_than_or_equal_to(0) }

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
  it { should have_many(:splits).dependent(:destroy) }
  it { should have_many(:inventories).class_name('Analyzable::Inventory') }

  describe 'servers' do
    it 'should return the servers and nothing else' do
      user.web_objects << FactoryBot.build(:web_object)
      user.web_objects << FactoryBot.build(:server)
      user.web_objects << FactoryBot.build(:server)
      user.web_objects << FactoryBot.build(:server)

      expect(user.servers.size).to eq 3
    end
  end

  describe 'terminal' do
    it 'should return the servers and nothing else' do
      owner.web_objects << FactoryBot.build(:web_object)
      owner.web_objects << FactoryBot.build(:terminal)
      owner.web_objects << FactoryBot.build(:terminal)

      expect(owner.terminals.size).to eq 2
    end
  end

  describe :email_changed? do
    it 'should be falsey' do
      expect(user.email_changed?).to be_falsey
    end
  end

  describe 'when a account_payment is received' do
    context 'for active user' do
      let(:active_user) { FactoryBot.create :active_user, account_level: 3 }

      it 'should correctly update expiration_date' do
        amount = Settings.default.account.monthly_cost * 3 * 2
        expected_expiration_date = active_user.expiration_date + 2.months.to_i
        active_user.update(account_payment: amount)
        expect(
          active_user.reload.expiration_date
        ).to be_within(1.second).of(expected_expiration_date)
      end
    end

    context 'for inactive_user' do
      let(:inactive_user) {
        FactoryBot.create :inactive_user, account_level: 2,
                                          expiration_date: 1.month.ago
      }

      it 'should correctly update expiration_date' do
        amount = Settings.default.account.monthly_cost * 2 * 2.25
        expected_expiration_date = Time.now + 1.month.to_i * 2.25
        inactive_user.update(account_payment: amount)
        expect(inactive_user.expiration_date).to be_within(1.second).of(expected_expiration_date)
      end
    end

    context 'and account level is zero' do
      let(:user) {
        FactoryBot.create :user, account_level: 0
      }
      it 'should correctly update expiration_date' do
        amount = Settings.default.account.monthly_cost * 1 * 2.35
        expected_expiration_date = Time.now + 1.month.to_i * 2.35
        user.update(account_payment: amount)
        expect(user.expiration_date).to be_within(1.second).of(expected_expiration_date)
      end
    end
  end

  describe 'updating the account_level' do
    context 'account level is greater than zero' do
      context 'and account level is increased' do
        let(:user) { FactoryBot.create :active_user, account_level: 1 }

        it 'should adjust the expiration_date correctly' do
          expected_expiration_date = Time.now + (user.expiration_date - Time.now) / 2
          user.update(account_level: 2)
          expect(user.expiration_date).to be_within(1.second).of(expected_expiration_date)
        end
      end

      context 'and account level is decreased' do
        context 'to greater than zero' do
          let(:user) { FactoryBot.create :active_user, account_level: 3 }
          it 'should adjust the expiration_date correctly' do
            expected_expiration_date = Time.now + (user.expiration_date - Time.now) * (3.to_f / 2)
            user.update(account_level: 2)
            expect(user.expiration_date).to be_within(1.second).of(expected_expiration_date)
          end
        end
        context 'to zero' do
          let(:user) { FactoryBot.create :active_user, account_level: 3 }
          it 'should adjust the expiration_date correctly' do
            expected_expiration_date = Time.now + (user.expiration_date - Time.now) * (0.to_f / 2)
            user.update(account_level: 0)
            expect(user.expiration_date).to be_within(1.second).of(expected_expiration_date)
          end
        end
      end
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

  describe 'split_percent' do
    it 'should return the total user splits' do
      user.splits << FactoryBot.build(:split, percent: 5)
      user.splits << FactoryBot.build(:split, percent: 10)
      user.splits << FactoryBot.build(:split, percent: 25)
      expect(user.split_percent).to eq 40
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
  
  describe 'adding transactions with splits' do
    let(:target_one) { FactoryBot.create :user }
    let(:target_two) { FactoryBot.create :avatar }
    let(:uri_regex) do
        %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
           auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
    end
    it 'should split the transaction from the user' do 
      stub_request(:post, uri_regex)
      user.web_objects << FactoryBot.build(:server)
      user.splits << FactoryBot.build(:split, percent: 5, 
                                              target_name: target_one.avatar_name, 
                                              target_key: target_one.avatar_key)
      user.splits << FactoryBot.build(:split, percent: 10, 
                                              target_name: target_two.avatar_name, 
                                              target_key: target_two.avatar_key)
      user.transactions << FactoryBot.build(:transaction, amount: 100)
      expect(user.transactions.size).to eq 3
    end
    
    it 'should send the requests to send money' do 
      stub = stub_request(:post, uri_regex)
      user.web_objects << FactoryBot.build(:server)
      user.splits << FactoryBot.build(:split, percent: 5, 
                                              target_name: target_one.avatar_name, 
                                              target_key: target_one.avatar_key)
      user.splits << FactoryBot.build(:split, percent: 10, 
                                              target_name: target_two.avatar_name, 
                                              target_key: target_two.avatar_key)
      user.transactions << FactoryBot.build(:transaction, amount: 100)
      expect(stub).to have_been_requested.times(2)
    end
    
    it 'should add the transction to the user if it exists' do 
      
      stub_request(:post, uri_regex)
      user.web_objects << FactoryBot.build(:server)
      user.splits << FactoryBot.build(:split, percent: 5, 
                                              target_name: target_one.avatar_name, 
                                              target_key: target_one.avatar_key)
      user.splits << FactoryBot.build(:split, percent: 10, 
                                              target_name: target_two.avatar_name, 
                                              target_key: target_two.avatar_key)
      user.transactions << FactoryBot.build(:transaction, amount: 100)
      expect(target_one.transactions.size).to eq 1
    end
  end
end
