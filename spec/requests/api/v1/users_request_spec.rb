# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:inactive_user) { FactoryBot.create :inactive_user }
  let(:new_user) { FactoryBot.build :inactive_user }
  let(:user_object) {
    object = FactoryBot.build(:web_object, user_id: inactive_user.id)
    object.save
    object
  }

  let(:owner) { FactoryBot.create :owner }
  let(:owner_object) {
    object = FactoryBot.build :web_object, user_id: owner.id
    object.save
    object
  }

  before(:each) do
    @existing_user = FactoryBot.create :active_user
  end

  describe 'creating an account' do
    let(:path) { api_users_path }

    context 'valid params' do
      let(:atts) {
        {
          avatar_name: new_user.avatar_name,
          avatar_key: new_user.avatar_key,
          password: 'Pa$sW0rd!',
          password_confirmation: 'Pa$sW0rd!'
        }
      }
      it 'should return created status' do
        post path, params: atts.to_json,
                   headers: headers(
                     user_object,
                     api_key: Settings.default.web_object.api_key
                   )
        expect(response.status).to eq 201
      end

      it 'should create a user' do
        # This forces the user to be created before teh expect block.
        # Otherwise we need to expect a change by 2, one for the user created
        web_object = user_object
        expect {
          post path, params: atts.to_json,
                     headers: headers(web_object, api_key: Settings.default.web_object.api_key)
        }.to change(User, :count).by(1)
      end

      it 'should return a nice message' do
        post path, params: atts.to_json,
                   headers: headers(
                     user_object,
                     api_key: Settings.default.web_object.api_key
                   )
        expect(JSON.parse(response.body)['message']).to eq(
          "Your account has been created. Please visit #{Settings.default.site_url} " \
          'to view your account.'
        )
      end
    end

    context 'invalid params' do
      context 'passwords do not match' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'Pa$sW0rd',
            password_confirmation: 'notaPa$sW0rd'
          }
        }
        it 'should return an error status' do
          post path, params: atts.to_json,
                     headers: headers(
                       user_object,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(response.status).to eq 422
        end

        it 'should return a message' do
          post path, params: atts.to_json,
                     headers: headers(
                       user_object,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(JSON.parse(response.body)['message']).to eq(
            "Validation failed: Password confirmation doesn't match Password"
          )
        end

        it 'should not create a user' do
          inactive_user
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         user_object,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to_not change(User, :count)
        end
      end

      context 'password in too short' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'Fo0!',
            password_confirmation: 'Fo0!'
          }
        }
        it 'should return an error status' do
          post path, params: atts.to_json,
                     headers: headers(
                       user_object,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(response.status).to eq 422
        end

        it 'should return a message' do
          post path, params: atts.to_json,
                     headers: headers(
                       user_object,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(JSON.parse(response.body)['message']).to eq(
            'Validation failed: Password is too short (minimum is 6 characters)'
          )
        end

        it 'should not create a user' do
          inactive_user
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         user_object,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to_not change(User, :count)
        end
      end

      context 'password in not complex enough' do
        let(:atts) {
          {
            avatar_name: new_user.avatar_name,
            avatar_key: new_user.avatar_key,
            password: 'password',
            password_confirmation: 'password'
          }
        }
        it 'should return an error status' do
          post path, params: atts.to_json,
                     headers: headers(
                       user_object,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(response.status).to eq 422
        end

        it 'should return a message' do
          post path, params: atts.to_json,
                     headers: headers(
                       user_object,
                       api_key: Settings.default.web_object.api_key
                     )
          expect(JSON.parse(response.body)['message']).to eq(
            'Validation failed: Password Complexity requirement not met. ' \
            'Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
          )
        end

        it 'should not create a user' do
          inactive_user
          expect {
            post path, params: atts.to_json,
                       headers: headers(
                         user_object,
                         api_key: Settings.default.web_object.api_key
                       )
          }.to_not change(User, :count)
        end
      end
    end
  end

  describe 'updating password' do
    let(:path) { api_user_path(@existing_user.avatar_key) }
    context 'valid params' do
      let(:atts) {
        {
          avatar_key: @existing_user.avatar_key,
          password: 'newPa$sW0rd',
          password_confirmation: 'newPa$sW0rd'
        }
      }

      it 'should return ok status' do
        put path, params: atts.to_json,
                  headers: headers(owner_object)
        expect(response.status).to eq 200
      end

      it 'should return a nice message' do
        put path, params: atts.to_json,
                  headers: headers(owner_object)
        expect(JSON.parse(response.body)['message']).to eq(
          'Your password has been updated.'
        )
      end

      it 'should not change user count' do
        owner
        expect {
          put path, params: atts.to_json,
                    headers: headers(owner_object)
        }.to_not change(User, :count)
      end

      it 'should update the password' do
        password_hash = @existing_user.encrypted_password
        put path, params: atts.to_json,
                  headers: headers(owner_object)
        expect(@existing_user.reload.encrypted_password).to_not eq(password_hash)
      end
    end

    context 'mismatched passwords' do
      let(:atts) {
        {
          avatar_key: @existing_user.avatar_key,
          password: 'newPa$sW0rd',
          password_confirmation: 'wrongnewPa$sW0rd'
        }
      }

      it 'should return an Unprocessable Entity status' do
        put path, params: atts.to_json,
                  headers: headers(owner_object)
        expect(response.status).to eq 422
      end

      it 'should not change the password' do
        password_hash = @existing_user.encrypted_password
        put path, params: atts.to_json,
                  headers: headers(owner_object)
        expect(@existing_user.reload.encrypted_password).to eq(password_hash)
      end
    end

    context 'invalid passwords' do
      let(:atts) {
        {
          avatar_key: @existing_user.avatar_key,
          password: 'password',
          password_confirmation: 'password'
        }
      }

      it 'should return an Unprocessable Entity status' do
        put path, params: atts.to_json,
                  headers: headers(owner_object)
        expect(response.status).to eq 422
      end

      it 'should not change the password' do
        password_hash = @existing_user.encrypted_password
        put path, params: atts.to_json,
                  headers: headers(owner_object)
        expect(@existing_user.reload.encrypted_password).to eq(password_hash)
      end
    end
  end

  describe 'showing an avatars info' do
    let(:path) { api_user_path(@existing_user.avatar_key) }

    it 'should return ok status' do
      get path, headers: headers(owner_object)
      expect(response.status).to eq 200
    end

    it 'should return some data' do
      get path, headers: headers(owner_object)
      expect(JSON.parse(response.body).with_indifferent_access['data']).to include(
        avatar_name: @existing_user.avatar_name,
        avatar_key: @existing_user.avatar_key,
        role: @existing_user.role,
        account_level: @existing_user.account_level,
        expiration_date: @existing_user.expiration_date.strftime('%B %-d, %Y')
      )
    end
  end

  describe 'deleting a user' do
    let(:path) { api_user_path(@existing_user.avatar_key) }
    it 'should return OK status' do
      delete path, headers: headers(owner_object)
      expect(response.status).to eq 200
    end

    it 'should return a nice message' do
      delete path, headers: headers(owner_object)
      expect(JSON.parse(response.body)['message']).to eq(
        'Your account has been deleted. Sorry to see you go!'
      )
    end

    it 'deletes the user' do
      owner_object
      expect {
        delete path, headers: headers(owner_object)
      }.to change(User, :count).by(-1)
    end
  end
end
