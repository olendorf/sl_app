# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AbstractWebObject, type: :model do
  it { should respond_to :api_key }
  # it { should belong_to(:user) }
  # it { should have_many(:transactions).class_name('Analyzable::Transaction').dependent(:nullify) }
  # it { should belong_to(:server) }

  it { should validate_presence_of :object_name }
  it { should validate_presence_of :object_key }
  it { should validate_presence_of :region }
  it { should validate_presence_of :position }
  it { should validate_presence_of :url }

  it { should be_actable }

  it { should belong_to(:user).optional(true) }
  it { should belong_to(:server).class_name('Rezzable::Server').optional(true) }

  it { should have_many(:splits).dependent(:destroy) }

  it { should respond_to :response_data }

  let(:user) { FactoryBot.create :owner }
  let(:web_object) do
    web_object = FactoryBot.build :abstract_web_object, user_id: user.id
    web_object.save
    web_object
  end

  describe 'active?' do
    it 'returns true when object has been pinged recently' do
      expect(web_object.active?).to be_truthy
    end

    it 'returns false when the object has not been pinged recently' do
      web_object.pinged_at = 1.hour.ago
      expect(web_object.active?).to be_falsey
    end
  end

  describe '#response_data' do
    it 'should return the api key' do
      expect(web_object.response_data).to include :api_key
    end
  end

  # describe 'adding transactions' do
  #   context 'no splits' do
  #     it 'should add the transaction to the user' do
  #       web_object.transactions << FactoryBot.build(:transaction, amount: 100)
  #       expect(user.transactions.size).to eq 1
  #     end
  #   end
  # end
end
