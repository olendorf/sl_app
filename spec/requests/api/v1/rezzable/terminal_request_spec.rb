# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::Terminals', type: :request do
  it_behaves_like 'it has an owner api', :terminal

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
      it 'should return ok status' do
        put path, params: atts.to_json, headers: headers(terminal)
        expect(response.status).to eq 200
      end

      it 'should add a transaction to the owner' do
        expect {
          put path, params: atts.to_json, headers: headers(terminal)
        }.to change(owner.transactions, :count).by(1)
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
      
      
      context 'and there are splits' do 
        let(:target_one) { FactoryBot.create :user }
        let(:target_two) { FactoryBot.create :avatar }
        let(:uri_regex) do
            %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
               auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
        end
        before(:each) do 
          @stub = stub_request(:post, uri_regex)
          server = FactoryBot.create :server, user_id: owner.id
          terminal.server_id = server.id
          terminal.splits << FactoryBot.build(
                                  :split, percent: 5, 
                                          target_name: target_one.avatar_name,
                                          target_key: target_one.avatar_key
                                    )
          terminal.splits << FactoryBot.build(
                                  :split, percent: 10, 
                                          target_name: target_two.avatar_name,
                                          target_key: target_two.avatar_key
                                    )
        end
        it 'should return ok status' do 
          put path, params: atts.to_json, headers: headers(terminal)
          expect(response.status).to eq 200
        end
        
        it 'should add the transactions to the user' do 
          terminal
          expect{
            put path, params: atts.to_json, headers: headers(terminal)
          }.to change(owner.transactions, :count).by(3)
        end
        
        it 'should make the requests to send the lindens' do 
          put path, params: atts.to_json, headers: headers(terminal)
          expect(@stub).to have_been_requested.times(2)
        end
        
        it 'should have the correct balance for the user' do 
          put path, params: atts.to_json, headers: headers(terminal)
          expect(owner.balance).to eq (amount - amount * 0.15)
        end
      end
      
      context 'server has splits' do         let(:target_one) { FactoryBot.create :user }
        let(:target_two) { FactoryBot.create :avatar }
        let(:uri_regex) do
            %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
               auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
        end
        before(:each) do 
          @stub = stub_request(:post, uri_regex)
          server = FactoryBot.create :server, user_id: owner.id
          terminal.server_id = server.id
          terminal.save
          server.splits << FactoryBot.build(
                                  :split, percent: 5, 
                                          target_name: target_one.avatar_name,
                                          target_key: target_one.avatar_key
                                    )
          server.splits << FactoryBot.build(
                                  :split, percent: 10, 
                                          target_name: target_two.avatar_name,
                                          target_key: target_two.avatar_key
                                    )
        end
        it 'should return ok status' do 
          put path, params: atts.to_json, headers: headers(terminal)
          expect(response.status).to eq 200
        end
        
                it 'should add the transactions to the user' do 
          terminal
          expect{
            put path, params: atts.to_json, headers: headers(terminal)
          }.to change(owner.transactions, :count).by(3)
        end
        
        it 'should make the requests to send the lindens' do 
          put path, params: atts.to_json, headers: headers(terminal)
          expect(@stub).to have_been_requested.times(2)
        end
        
        it 'should have the correct balance for the user' do 
          put path, params: atts.to_json, headers: headers(terminal)
          expect(owner.balance).to eq (amount - amount * 0.15)
        end
      end
    end
  end
end
