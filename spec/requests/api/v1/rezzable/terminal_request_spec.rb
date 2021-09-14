# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::Terminals', type: :request do
  it_behaves_like 'it has an owner api', :terminal

  it_behaves_like 'it takes payments', :terminal, :owner, 900

  # describe 'making a payment' do
  #   let(:owner) do
  #     owner = FactoryBot.create :owner
  #     owner.web_objects << FactoryBot.build(:server)
  #     owner
  #   end
  #   let(:active_user) { FactoryBot.create :active_user }
  #   let(:terminal) { FactoryBot.create :terminal, user_id: owner.id }
  #   let(:path) { api_rezzable_terminal_path(owner) }
  #   let(:amount) { Settings.default.account.monthly_cost * 3 * active_user.account_level }
  #   let(:uri_regex) {
  #     %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
  #                         auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  #   }
  #   context 'valid params' do
  #     let(:atts) {
  #       {
  #         transactions_attributes: [{
  #           amount: amount,
  #           target_name: active_user.avatar_name,
  #           target_key: active_user.avatar_key
  #         }]
  #       }
  #     }

  #     it 'should extend the targets expiration date' do
  #       expected = active_user.expiration_date + 3.months.seconds
  #       put path, params: atts.to_json, headers: headers(terminal)
  #       expect(active_user.reload.expiration_date).to be_within(2.seconds).of(expected)
  #     end

  #     it 'should add a transaction to the user' do
  #       expect {
  #         put path, params: atts.to_json, headers: headers(terminal)
  #       }.to change(active_user.transactions, :count).by(1)
  #     end

  #     it 'should return a nice message' do
  #       put path, params: atts.to_json, headers: headers(terminal)
  #       expect(JSON.parse(response.body)['message']).to include(
  #         'Thank you for your payment. Your new expiration date is'
  #       )
  #     end

  #     context 'and there are user splits' do
  #       let(:split_user) { FactoryBot.create :user }
  #       before(:each) do
  #         owner.splits << FactoryBot.build(
  #           :split, percent: 5,
  #                   target_name: split_user.avatar_name,
  #                   target_key: split_user.avatar_key
  #         )
  #         owner.splits << FactoryBot.build(:split, percent: 10)
  #         owner.splits << FactoryBot.build(:split, percent: 7)
  #         body_regex = /"avatar_name":"[a-zA-Z' ]+","amount":[0-9]+/
  #         @stub = stub_request(:post, uri_regex).with(body: body_regex)
  #       end

  #       it 'adds transactions to the owners account' do
  #         expect {
  #           put path, params: atts.to_json, headers: headers(terminal)
  #         }.to change(owner.reload.transactions, :count).by(4)
  #       end

  #       it 'updates the owners balance correctl' do
  #         trans_atts = atts[:transactions_attributes][0]
  #         expected_balance = trans_atts[:amount] - (trans_atts[:amount] * 0.05).round -
  #                           (trans_atts[:amount] * 0.1).round -
  #                           (trans_atts[:amount] * 0.07).round
  #         put path, params: atts.to_json, headers: headers(terminal)
  #         expect(owner.reload.balance).to eq expected_balance
  #       end

  #       it 'adds transactions to the existing sharees' do
  #         expect {
  #           put path, params: atts.to_json, headers: headers(terminal)
  #         }.to change(split_user.transactions, :count).by(1)
  #       end

  #       it 'updates the sharees balance' do
  #         trans_atts = atts[:transactions_attributes][0]
  #         put path, params: atts.to_json, headers: headers(terminal)
  #         expect(split_user.balance).to eq((trans_atts[:amount] * 0.05).round)
  #       end

  #       it 'sends the payment to the payee' do
  #         put path, params: atts.to_json, headers: headers(terminal)
  #         expect(@stub).to have_been_requested.times(3)
  #       end
  #     end
  #   end
  # end
end
