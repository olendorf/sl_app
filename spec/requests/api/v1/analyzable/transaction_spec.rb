# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Analyzable::Transactions', type: :request do
  let(:user) { FactoryBot.create :active_user }
  let(:web_object) {
    FactoryBot.create :server, user_id: user.id
  }

  describe 'POST' do
    let(:path) { api_analyzable_transactions_path }

    let(:atts) {
      FactoryBot.attributes_for :transaction,
                                amount: rand(-1000..-1),
                                description: 'Direct payment'
    }

    it 'should return created status' do
      post path, params: atts.to_json, headers: headers(web_object)

      expect(response.status).to eq 201
    end

    it 'should create the transation' do
      expect {
        post path, params: atts.to_json, headers: headers(web_object)
      }.to change(user.transactions, :count).by(1)
    end
  end
end
