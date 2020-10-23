# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ApiController, type: :controller do
  controller do
    skip_after_action :verify_authorized
    def index
      render json: { message: 'yay' }
    end

    def create
      render json: { message: 'yay' }, status: :created
    end
  end

  let(:user) { FactoryBot.create :user }
  let(:requesting_object) do
    object = FactoryBot.build :web_object, user_id: user.id
    object.save
    object
  end

  describe 'create' do
    context 'with valid package' do
      it 'should return ok status' do
        time = Time.now.to_i
        @request.env['HTTP_X_AUTH_TIME'] = time
        @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
          time.to_s + Settings.default.web_object.api_key
        )
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = SecureRandom.uuid
        post :create
        expect(response.status).to eq 201
      end
    end

    context 'with invalid api_key' do
      it 'should return bad request status' do
        time = Time.now.to_i
        @request.env['HTTP_X_AUTH_TIME'] = time
        @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
          "#{time}invalid"
        )
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = SecureRandom.uuid
        post :create
        expect(response.status).to eq 400
      end
    end

    context 'missing time' do
      it 'should return ok status' do
        @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
          to_s + Settings.default.web_object.api_key
        )
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = SecureRandom.uuid
        post :create
        expect(response.status).to eq 400
      end
    end

    context 'stale time' do
      it 'should return ok status' do
        time = Time.now.to_i - 60
        @request.env['HTTP_X_AUTH_TIME'] = time
        @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
          time.to_s + Settings.default.web_object.api_key
        )
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = SecureRandom.uuid
        post :create
        expect(response.status).to eq 400
      end
    end

    context 'future time' do
      it 'should return ok status' do
        time = Time.now.to_i + 60
        @request.env['HTTP_X_AUTH_TIME'] = time
        @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
          time.to_s + Settings.default.web_object.api_key
        )
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = SecureRandom.uuid
        post :create
        expect(response.status).to eq 400
      end
    end
  end

  # THis and create are really the only two unique cases
  # Update, destroy and show all follow the same rules
  describe 'show' do
    context 'with valid package' do
      it 'should return ok status' do
        time = Time.now.to_i
        @request.env['HTTP_X_AUTH_TIME'] = time
        @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
          time.to_s + requesting_object.api_key
        )
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = requesting_object.object_key
        get :index
        expect(response.status).to eq 200
      end
    end

    context 'with missing auth time' do
      before(:each) do
        @request.env['HTTP_X_AUTH_DIGEST'] = 'foo'
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = requesting_object.object_key
      end

      it 'should return bad request status' do
        get :index
        expect(response.status).to eq 400
      end
      it 'should return a helpful message' do
        get :index
        expect(JSON.parse(response.body)['message']).to eq I18n.t('errors.auth_time')
      end
    end

    context 'with stale auth time' do
      before(:each) do
        time = 1.minute.ago.to_i
        @request.env['HTTP_X_AUTH_TIME'] = time
        @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
          time.to_s + requesting_object.api_key
        )
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = requesting_object.object_key
      end
      it 'should return bad request status' do
        get :index
        expect(response.status).to eq 400
      end
      it 'should return a helpful message' do
        get :index
        expect(JSON.parse(response.body)['message']).to eq I18n.t('errors.auth_time')
      end
    end

    context 'with missing auth digest' do
      before(:each) do
        @request.env['HTTP_X_AUTH_TIME'] = Time.now.to_i
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = requesting_object.object_key
      end

      it 'should return bad request status' do
        get :index
        expect(response.status).to eq 400
      end
      it 'should return a helpful message' do
        get :index
        expect(JSON.parse(response.body)['message']).to eq I18n.t('errors.auth_digest')
      end
    end

    context 'context invalid digest' do
      before(:each) do
        @request.env['HTTP_X_AUTH_TIME'] = Time.now.to_i
        @request.env['HTTP_X_AUTH_DIGEST'] = 'foo'
        @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = requesting_object.object_key
      end
      it 'should return ok status' do
        get :index
        expect(response.status).to eq 400
      end

      it 'should return a helpful message' do
        get :index
        expect(JSON.parse(response.body)['message']).to eq I18n.t('errors.auth_digest')
      end
    end
  end
end
