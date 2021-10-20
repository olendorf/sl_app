# frozen_string_literal: true

RSpec.shared_examples 'it takes payments' do |model_name, user_type, amount|
  let(:user) { FactoryBot.create user_type.to_sym }
  let(:web_object) { FactoryBot.create model_name.to_sym, user_id: user.id }
  let(:active_user) { FactoryBot.create :active_user }
  let(:path) { send("api_rezzable_#{model_name}_path", web_object) }

  describe 'making a payment' do
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
        put path, params: atts.to_json, headers: headers(web_object)
        expect(response.status).to eq 200
      end

      it 'should add a transaction to the object owner' do
        expect {
          put path, params: atts.to_json, headers: headers(web_object)
        }.to change(user.transactions, :count).by(1)
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
          server = FactoryBot.create :server, user_id: user.id
          web_object.server_id = server.id
          web_object.splits << FactoryBot.build(
            :split, percent: 5,
                    target_name: target_one.avatar_name,
                    target_key: target_one.avatar_key
          )
          web_object.splits << FactoryBot.build(
            :split, percent: 10,
                    target_name: target_two.avatar_name,
                    target_key: target_two.avatar_key
          )
        end
        it 'should return ok status' do
          put path, params: atts.to_json, headers: headers(web_object)
          expect(response.status).to eq 200
        end

        it 'should add the transactions to the user' do
          # terminal
          expect {
            put path, params: atts.to_json, headers: headers(web_object)
          }.to change(user.transactions, :count).by(3)
        end

        it 'should make the requests to send the lindens' do
          put path, params: atts.to_json, headers: headers(web_object)
          expect(@stub).to have_been_requested.times(2)
        end

        it 'should have the correct balance for the user' do
          put path, params: atts.to_json, headers: headers(web_object)
          expect(user.balance).to eq(amount - (amount * 0.15))
        end
      end

      context 'server has splits' do
        let(:target_one) { FactoryBot.create :user }
        let(:target_two) { FactoryBot.create :avatar }
        let(:uri_regex) do
          %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
             auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
        end
        before(:each) do
          @stub = stub_request(:post, uri_regex)
          server = FactoryBot.create :server, user_id: user.id
          web_object.server_id = server.id
          web_object.save
          web_object.splits << FactoryBot.build(
            :split, percent: 5,
                    target_name: target_one.avatar_name,
                    target_key: target_one.avatar_key
          )
          web_object.splits << FactoryBot.build(
            :split, percent: 10,
                    target_name: target_two.avatar_name,
                    target_key: target_two.avatar_key
          )
        end
        it 'should return ok status' do
          put path, params: atts.to_json, headers: headers(web_object)
          expect(response.status).to eq 200
        end

        it 'should add the transactions to the user' do
          # terminal
          expect {
            put path, params: atts.to_json, headers: headers(web_object)
          }.to change(user.transactions, :count).by(3)
        end

        it 'should make the requests to send the lindens' do
          put path, params: atts.to_json, headers: headers(web_object)
          expect(@stub).to have_been_requested.times(2)
        end

        it 'should have the correct balance for the user' do
          put path, params: atts.to_json, headers: headers(web_object)
          expect(user.balance).to eq(amount - (amount * 0.15))
        end
      end
    end
  end
end
