# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::Terminals', type: :request do
  it_behaves_like 'it has an owner api', :terminal
  
  it_behaves_like 'it takes payments', :terminal, :owner, 900

  describe 'making a payment' do
    let(:owner) { FactoryBot.create :owner }
    let(:active_user) { FactoryBot.create :active_user }
    let(:terminal) { FactoryBot.create :terminal, user_id: owner.id }
    let(:path) { api_rezzable_terminal_path(owner) }
    let(:amount) { Settings.default.account.monthly_cost * 3 * active_user.account_level }

    context 'valid params' do
      let(:atts) {
        {
          transactions_attributes: [{
            amount: amount,
            target_name: active_user.avatar_name,
            target_key: active_user.avatar_key
          }]
        }
      }
      
      it 'should extend the targets expiration date' do 
        expected = active_user.expiration_date + 3.months.seconds
        put path, params: atts.to_json, headers: headers(terminal)
        expect(active_user.reload.expiration_date).to be_within(2.seconds).of(expected)
      end

      it 'should add a transaction to the user' do
        expect {
          put path, params: atts.to_json, headers: headers(terminal)
        }.to change(active_user.transactions, :count).by(1)
      end

      it 'should return a nice message' do
        put path, params: atts.to_json, headers: headers(terminal)
        expect(JSON.parse(response.body)['message']).to include(
          'Thank you for your payment. Your new expiration date is'
        )
      end
    end
  end
end
