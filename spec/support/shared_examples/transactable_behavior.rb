# frozen_string_literal: true

RSpec.shared_examples 'it is a transactable' do |model_name|
  it {
    should have_many(:transactions)
      .class_name('Analyzable::Transaction')
      .dependent(:nullify)
  }

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:transactable) { FactoryBot.create model_name.to_sym, user_id: user.id }

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  before(:each) { server }

  describe 'adding transactions' do
    context 'no splits' do
      it 'should add the transaction to the user' do
        transactable.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(user.transactions.size).to eq 1
      end

      it 'should have the correct balance' do
        transactable.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(user.transactions.last.balance).to eq 100
      end
    end

    context 'splits' do
      before(:each) {
        @stub = stub_request(:post, uri_regex)
                .with(body: /{"avatar_name":"[a-zA-Z0-9' ]*","amount":[0-9]+}/)
                .to_return(status: 200, body: '', headers: {})
      }
      it 'should add the transactions to the user' do
        user.splits << FactoryBot.build(:split, percent: 5)
        transactable.splits << FactoryBot.build(:split, percent: 10)
        transactable.splits << FactoryBot.build(:split, percent: 20)
        transactable.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(user.transactions.size).to eq 4
      end

      it 'should request the money to be given' do
        user.splits << FactoryBot.build(:split, percent: 5)
        transactable.splits << FactoryBot.build(:split, percent: 10)
        transactable.splits << FactoryBot.build(:split, percent: 20)
        transactable.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(@stub).to have_been_made.times(3)
      end

      it 'should end in the correct balance' do
        user.splits << FactoryBot.build(:split, percent: 5)
        transactable.splits << FactoryBot.build(:split, percent: 10)
        transactable.splits << FactoryBot.build(:split, percent: 20)
        transactable.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(user.balance).to eq 65
      end

      it 'should add the transaction to the target if they have an account' do
        target = FactoryBot.create(:active_user)
        user.splits << FactoryBot.build(:split, percent: 5)
        transactable.splits << FactoryBot.build(:split, target_name: target.avatar_name,
                                                        target_key: target.avatar_key,
                                                        percent: 10)
        transactable.splits << FactoryBot.build(:split, percent: 20)
        transactable.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(target.transactions.size).to eq 1
      end
      it 'should set the targets balance' do
        target = FactoryBot.create(:active_user)
        user.splits << FactoryBot.build(:split, percent: 5)
        transactable.splits << FactoryBot.build(:split, target_name: target.avatar_name,
                                                        target_key: target.avatar_key,
                                                        percent: 10)
        transactable.splits << FactoryBot.build(:split, percent: 20)
        transactable.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(target.balance).to eq 10
      end
    end
  end
  # expect(a_request(:post, "www.something.com")).to have_been_made.times(3)
end
