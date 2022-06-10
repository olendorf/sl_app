# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  
  include ActionView::Helpers::DateHelper
  
  let(:owner) { FactoryBot.create :owner }
  let(:terminal) {
    terminal = FactoryBot.build :terminal, user_id: owner.id
    terminal.save
    terminal
  }

  let(:uri_regex) do
    %r{
        \Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}
        \?auth_digest=[a-f0-9]+&auth_time=[0-9]+\z
    }x
  end
  describe 'creating an account' do
    # Users can create accounts from registrationers that cmoe
    # with a purchased package OR from a terminal. Registrationers
    # always assume that the avatar has paid and therefore gets
    # a one month account of level 1.
    # context 'from a registrationer' do
    #   let(:registrationer) { FactoryBot.build :web_object }

    #   let(:new_user) { FactoryBot.build :inactive_user }

    #   let(:path) { api_users_path }

    #   context 'valid params' do
    #     let(:atts) {
    #       {
    #         avatar_name: new_user.avatar_name,
    #         avatar_key: new_user.avatar_key,
    #         password: 'Pa$sW0rd!',
    #         password_confirmation: 'Pa$sW0rd!',
    #         account_payment: 0,
    #         # expiration_date: Time.now + 1.month.to_i,
    #         added_time: 1,
    #         account_level: 1
    #       }
    #     }
    #     it 'should return created status' do
    #       post path, params: atts.to_json,
    #                 headers: headers(
    #                   registrationer,
    #                   api_key: Settings.default.web_object.api_key,
    #                   avatar_key: SecureRandom.uuid
    #                 )
    #       expect(response.status).to eq 201
    #     end

    #     it 'should create a user' do
    #       expect {
    #         post path, params: atts.to_json,
    #                   headers: headers(
    #                     registrationer,
    #                     api_key: Settings.default.web_object.api_key,
    #                     avatar_key: SecureRandom.uuid
    #                   )
    #       }.to change(User, :count).by(1)
    #     end

    #     it 'should set the parameters correctly' do
    #       post path, params: atts.to_json,
    #                 headers: headers(
    #                   registrationer,
    #                   api_key: Settings.default.web_object.api_key,
    #                   avatar_key: SecureRandom.uuid
    #                 )
    #       expect(User.last.attributes.with_indifferent_access).to include(
    #         avatar_name: atts[:avatar_name],
    #         avatar_key: atts[:avatar_key],
    #         account_level: atts[:account_level]
    #       )
    #       expect(User.last.expiration_date).to be_within(30).of(Time.now + 1.month.to_i)
    #     end

    #     it 'should return a nice message' do
    #       post path, params: atts.to_json,
    #                 headers: headers(
    #                   registrationer,
    #                   api_key: Settings.default.web_object.api_key,
    #                   avatar_key: SecureRandom.uuid
    #                 )
    #       expect(JSON.parse(response.body)['message']).to eq(
    #         'Your account has been created. Please ' +
    #         "visit #{Settings.default.site_url} to " +
    #         'view your account.'
    #       )
    #     end
    #     it 'should return the correct data' do
    #       post path, params: atts.to_json,
    #                 headers: headers(
    #                   registrationer,
    #                   api_key: Settings.default.web_object.api_key,
    #                   avatar_key: SecureRandom.uuid
    #                 )
    #       expect(JSON.parse(response.body)['data'].with_indifferent_access).to include(
    #         'payment_schedule',
    #         avatar_name: atts[:avatar_name],
    #         avatar_key: atts[:avatar_key],
    #         time_left: distance_of_time_in_words(
    #             Time.now, User.last.expiration_date),
    #         account_level: atts[:account_level]
    #       )
    #     end
    #   end
    # end

    describe 'invalid params' do
      let(:registrationer) { FactoryBot.build :web_object }

      let(:new_user) { FactoryBot.build :inactive_user }

      let(:path) { api_users_path }
      context 'password is too short' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'P0rd!',
            password_confirmation: 'P0rd!',
            account_payment: 0,
            added_time: 1,
            account_level: 1
          }
        }

        it 'should return unprocessable enttiy' do
          post path, params: atts.to_json,
                    headers: headers(
                      registrationer,
                      api_key: Settings.default.web_object.api_key,
                      avatar_key: SecureRandom.uuid
                    )
          expect(response.status).to eq 422
        end

        it 'should not create a user' do
          expect {
            post path, params: atts.to_json,
                      headers: headers(
                        registrationer,
                        api_key: Settings.default.web_object.api_key,
                        avatar_key: SecureRandom.uuid
                      )
          }.to_not change(User, :count)
        end

        it 'should return a nice message' do
          post path, params: atts.to_json,
                    headers: headers(
                      registrationer,
                      api_key: Settings.default.web_object.api_key,
                      avatar_key: SecureRandom.uuid
                    )
          expect(JSON.parse(response.body)['message']).to eq(
            'Validation failed: Password is too short (minimum is 6 characters)'
          )
        end
      end

      context 'password is not complex' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'password1',
            password_confirmation: 'password1',
            account_payment: 0,
            # expiration_date: Time.now + 1.month.to_i,
            added_time: 1,
            account_level: 1
          }
        }

        it 'should return unprocessable enttiy' do
          post path, params: atts.to_json,
                    headers: headers(
                      registrationer,
                      api_key: Settings.default.web_object.api_key,
                      avatar_key: SecureRandom.uuid
                    )
          expect(response.status).to eq 422
        end

        it 'should not create a user' do
          expect {
            post path, params: atts.to_json,
                      headers: headers(
                        registrationer,
                        api_key: Settings.default.web_object.api_key,
                        avatar_key: SecureRandom.uuid
                      )
          }.to_not change(User, :count)
        end

        it 'should return a nice message' do
          post path, params: atts.to_json,
                    headers: headers(
                      registrationer,
                      api_key: Settings.default.web_object.api_key,
                      avatar_key: SecureRandom.uuid
                    )
          expect(JSON.parse(response.body)['message']).to eq(
            'Validation failed: Password Complexity requirement not met. ' +
            'Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
          )
        end
      end

      context 'passwords dont match' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'Pa$sW0rd',
            password_confirmation: 'Pa$sW0rt',
            account_payment: 0,
            # expiration_date: Time.now + 1.month.to_i,
            added_time: 1,
            account_level: 1
          }
        }

        it 'should return unprocessable enttiy' do
          post path, params: atts.to_json,
                    headers: headers(
                      registrationer,
                      api_key: Settings.default.web_object.api_key,
                      avatar_key: SecureRandom.uuid
                    )
          expect(response.status).to eq 422
        end

        it 'should not create a user' do
          expect {
            post path, params: atts.to_json,
                      headers: headers(
                        registrationer,
                        api_key: Settings.default.web_object.api_key,
                        avatar_key: SecureRandom.uuid
                      )
          }.to_not change(User, :count)
        end

        it 'should return a nice message' do
          post path, params: atts.to_json,
                    headers: headers(
                      registrationer,
                      api_key: Settings.default.web_object.api_key,
                      avatar_key: SecureRandom.uuid
                    )
          expect(JSON.parse(response.body)['message']).to eq(
            "Validation failed: Password confirmation doesn't match Password"
          )
        end
      end

      context 'user exists' do
        let(:existing_user) { FactoryBot.create :inactive_user }
        let(:atts) {
          {
            avatar_name: existing_user.avatar_name,
            avatar_key: existing_user.avatar_key,
            password: 'Pa$sW0rd!',
            password_confirmation: 'Pa$sW0rd!',
            account_payment: 0,
            # expiration_date: Time.now + 1.month.to_i,
            added_time: 1,
            account_level: 1
          }
        }

        it 'should return conflict status' do
          post path, params: atts.to_json,
                    headers: headers(
                      registrationer,
                      api_key: Settings.default.web_object.api_key,
                      avatar_key: SecureRandom.uuid
                    )
          expect(response.status).to eq 409
        end

        it 'should not create a user' do
          existing_user
          expect {
            post path, params: atts.to_json,
                      headers: headers(
                        registrationer,
                        api_key: Settings.default.web_object.api_key,
                        avatar_key: SecureRandom.uuid
                      )
          }.to_not change(User, :count)
        end
      end
    end

    # TErminals can create users and take payments at the same time
    # allowing more flexibility in user creation.
    context 'from a terminal' do
      let(:owner) { FactoryBot.create :owner }
      let(:new_user) { FactoryBot.build :inactive_user }
      let(:terminal) {
        terminal = FactoryBot.build :terminal, user_id: owner.id
        terminal.save
        terminal
      }
      let(:path) { api_users_path }

      context 'user makes 1 month payment' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'Pa$sW0rd!',
            password_confirmation: 'Pa$sW0rd!',
            account_payment: Settings.default.account.monthly_cost,
            # expiration_date: Time.now + 1.month.to_i,
            added_time: 1,
            account_level: 1
          }
        }

        it 'should create a transaction for the owner' do
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         terminal,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to change(owner.transactions, :count).by(1)
        end

        it 'should return created status' do
          post path, params: atts.to_json,
                     headers: headers(
                       terminal,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(response.status).to eq 201
        end

        it 'should create a user' do
          owner
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         terminal,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to change(User, :count).by(1)
        end

        it 'should set the attributes correctly' do
          post path, params: atts.to_json,
                     headers: headers(
                       terminal,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(User.last.attributes.with_indifferent_access).to include(
            avatar_name: atts[:avatar_name],
            avatar_key: atts[:avatar_key],
            account_level: atts[:account_level]
          )
          expect(User.last.expiration_date).to be_within(30).of(Time.now + 1.month.to_i)
        end
      end

      context 'user wants zero level account' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'Pa$sW0rd!',
            password_confirmation: 'Pa$sW0rd!',
            account_payment: 0,
            added_time: 0,
            account_level: 0
          }
        }

        it 'should return created status' do
          post path, params: atts.to_json,
                     headers: headers(
                       terminal,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(response.status).to eq 201
        end

        it 'should create a user' do
          owner
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         terminal,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to change(User, :count).by(1)
        end

        it 'should set the attributes correctly' do
          post path, params: atts.to_json,
                     headers: headers(
                       terminal,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(User.last.attributes.with_indifferent_access).to include(
            avatar_name: atts[:avatar_name],
            avatar_key: atts[:avatar_key],
            account_level: 0
          )
          expect(User.last.expiration_date).to be_within(30).of(Time.now)
        end
      end

      context 'user pays for 3 months' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'Pa$sW0rd!',
            password_confirmation: 'Pa$sW0rd!',
            account_payment: 3 * Settings.default.account.monthly_cost,
            added_time: 3,
            account_level: 1
          }
        }
        it 'should return created status' do
          post path, params: atts.to_json,
                     headers: headers(
                       terminal,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(response.status).to eq 201
        end

        it 'should create a transaction for the owner' do
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         terminal,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to change(owner.transactions, :count).by(1)
        end

        it 'should create a user' do
          owner
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         terminal,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to change(User, :count).by(1)
        end

        it 'should set the attributes correctly' do
          post path, params: atts.to_json,
                     headers: headers(
                       terminal,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(User.last.attributes.with_indifferent_access).to include(
            avatar_name: atts[:avatar_name],
            avatar_key: atts[:avatar_key],
            account_level: atts[:account_level]
          )
          expect(User.last.expiration_date).to be_within(10.seconds).of(Time.now + 3.months.to_i)
        end
      end
    end
  end

  describe 'getting account data' do
    context 'activer user' do
      let(:active_user) { FactoryBot.create :active_user }
      let(:path) { api_user_path(active_user.avatar_key) }
      it 'should return ok status' do
        get path, headers: headers(terminal)
        expect(response.status).to eq 200
      end

      it 'should return the correct data' do
        get path, headers: headers(terminal)
        expect(JSON.parse(response.body)['data'].with_indifferent_access).to include(
          'payment_schedule',
          avatar_name: active_user.avatar_name,
          avatar_key: active_user.avatar_key,
          time_left: distance_of_time_in_words(
                Time.now, active_user.expiration_date),
          account_level: active_user.account_level
        )
      end
    end

    context 'inactive_user' do
      let(:inactive_user) { FactoryBot.create :inactive_user }
      let(:path) { api_user_path(inactive_user.avatar_key) }
      it 'should return ok status' do
        get path, headers: headers(terminal)
        expect(response.status).to eq 200
      end

      it 'should return the correct data' do
        get path, headers: headers(terminal)
        expect(JSON.parse(response.body)['data'].with_indifferent_access).to include(
          'payment_schedule',
          avatar_name: inactive_user.avatar_name,
          avatar_key: inactive_user.avatar_key,
          time_left: "Inactive",
          account_level: inactive_user.account_level
        )
      end
    end

    context 'user does not exist' do
      let(:path) { api_user_path(SecureRandom) }
      it 'should return ok status' do
        get path, headers: headers(terminal)
        expect(response.status).to eq 404
      end

      it 'should return the correct data' do
        get path, headers: headers(terminal)
        expect(JSON.parse(
          response.body)).to include(
          "message" =>"User not found.", 
          "data" => {"payment_schedule" => {"1620" => 6, "300" => 1, "3060" => 12, "855" => 3}}
        )
      end
    end
  end

  describe 'updating an account' do
    context 'user exists' do
      let(:existing_user) { FactoryBot.create :active_user }
      let(:path) { api_user_path(existing_user.avatar_key) }
      describe 'changing passwords' do
        context 'valid passwords' do
          let(:atts) {
            {
              password: 'N3wPassword!',
              password_confirmation: 'N3wPassword!'
            }
          }

          it 'should return ok status' do
            put path, params: atts.to_json, headers: headers(terminal)
            expect(response.status).to eq 200
          end

          it 'should change the password' do
            old_password = existing_user.encrypted_password
            put path, params: atts.to_json, headers: headers(terminal)
            expect(
              existing_user.reload.encrypted_password).to_not eq old_password
          end

          it 'returns the correct data' do
            put path, params: atts.to_json, headers: headers(terminal)
            expect(JSON.parse(
              response.body)['data'].with_indifferent_access).to include(
              'payment_schedule',
              avatar_name: existing_user.avatar_name,
              avatar_key: existing_user.avatar_key,
              time_left: distance_of_time_in_words(
                Time.now, existing_user.expiration_date),
              account_level: existing_user.account_level
            )
          end

          it 'returns a nice message' do
            put path, params: atts.to_json, headers: headers(terminal)
            expect(JSON.parse(response.body)['message']).to eq 'Your account has been updated.'
          end
        end

        # Only check that it works over all. Extensive testing
        # done with create testing.
        context 'invalid passwords' do
          let(:atts) {
            {
              password: 'N3wPassword!',
              password_confirmation: 'foo!'
            }
          }

          it 'should return ok status' do
            put path, params: atts.to_json, headers: headers(terminal)
            expect(response.status).to eq 422
          end

          it 'should not change the password' do
            old_password = existing_user.encrypted_password
            put path, params: atts.to_json, headers: headers(terminal)
            expect(existing_user.reload.encrypted_password).to eq old_password
          end
        end
      end

      describe 'changing account level' do
        let(:atts) { { account_level: 3 } }

        it 'returns ok status' do
          put path, params: atts.to_json, headers: headers(terminal)
          expect(response.status).to eq 200
        end

        it 'changes the account level' do
          put path, params: atts.to_json, headers: headers(terminal)
          expect(existing_user.reload.account_level).to eq 3
        end

        it 'correctly alters time left' do
          expected_time = Time.now + ((
            existing_user.expiration_date.to_i - Time.now.to_i) * (1.0 / 3))
          expected_time = Time.diff(expected_time, Time.now)
          put path, params: atts.to_json, headers: headers(terminal)
          expect(existing_user.reload.time_left).to eq expected_time
        end
      end

      describe 'making a payment' do
        before(:each) do
          @stub = stub_request(:put, uri_regex)
        end

        let(:atts) {
          {
            # added_time: 3,
            account_payment: Settings.default.account.monthly_cost *
              3 * existing_user.account_level
          }
        }

        it 'returns ok status' do
          put path, params: atts.to_json, headers: headers(terminal)
          expect(response.status).to eq 200
        end

        it 'updates the expiration_date' do
          expected_time = existing_user.expiration_date +
                          (atts[:account_payment].to_f / (
                            existing_user.account_level * Settings.default.account.monthly_cost
                          ) * 1.month.to_i)
          put path, params: atts.to_json, headers: headers(terminal)
          expect(existing_user.reload.expiration_date).to be_within(10.seconds).of(expected_time)
        end

        it 'adds the transaction to the user' do
          put path, params: atts.to_json, headers: headers(terminal)
          expect(existing_user.reload.transactions.size).to eq 1
        end

        it 'adds the transaction to the owner' do
          put path, params: atts.to_json, headers: headers(terminal)
          expect(owner.reload.transactions.size).to eq 1
        end
      end

      #   it 'adds a transaction' do
      #     expect {
      #       put path, params: atts.to_json, headers: headers(terminal)
      #     }.to change(owner.reload.transactions, :count).by(1)
      #   end

      #   describe 'and there are user splits' do
      #     let(:target_user) { FactoryBot.create :active_user }
      #     before(:each) do
      #       owner.splits << FactoryBot.build(:split, percent: 5)
      #       owner.splits << FactoryBot.build(:split, percent: 10,
      #                                               target_key: target_user.avatar_key,
      #                                               target_name: target_user.avatar_name)
      #       terminal.splits << FactoryBot.build(:split, percent: 7)
      #     end
      #     it 'adds transactions to the owners account' do
      #       expect {
      #         put path, params: atts.to_json, headers: headers(terminal)
      #       }.to change(owner.reload.transactions, :count).by(3)
      #     end

      #     it 'updates the owners balance correctl' do
      #       expected_balance = atts[:account_payment] - (atts[:account_payment] * 0.05).round -
      #                         (atts[:account_payment] * 0.1).round -
      #                         (atts[:account_payment] * 0.07).round
      #       put path, params: atts.to_json, headers: headers(terminal)
      #       expect(owner.reload.balance).to eq expected_balance
      #     end

      #     it 'adds transactions to the existing sharees' do
      #       expect {
      #         put path, params: atts.to_json, headers: headers(terminal)
      #       }.to change(target_user.transactions, :count).by(1)
      #     end

      #     it 'updates the sharees balance' do
      #       put path, params: atts.to_json, headers: headers(terminal)
      #       expect(target_user.balance).to eq((atts[:account_payment] * 0.1).round)
      #     end

      #     it 'sends the payment to the payee' do
      #       put path, params: atts.to_json, headers: headers(terminal)
      #       expect(@stub).to have_been_requested.times(3)
      #     end
      #   end
      # end
    end
  end

  describe 'deleting an account' do
    let(:existing_user) { FactoryBot.create :user }
    let(:path) { api_user_path(existing_user.avatar_key) }
    it 'returns ok status' do
      delete path, headers: headers(terminal)
      expect(response.status).to eq 200
    end

    it 'deletes the user' do
      existing_user
      owner
      expect {
        delete path, headers: headers(terminal)
      }.to change(User, :count).by(-1)
    end

    it 'returns a nice message' do
      delete path, headers: headers(terminal)
      expect(
        JSON.parse(response.body)['message']
      ).to eq 'Your account has been deleted. Sorry to see you go!'
    end
  end
end
