# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AbstractWebObjectsController, type: :controller do
  # controller do
  #   skip_after_action :verify_authorized

  #   def create
  #     new_object = AbstractWebObject.create(atts)

  #     render json:  {
  #                     data: {api_key: new_object.api_key},
  #                     msg: 'Created'
  #                   }, status: :created

  #   end
  # end

  # let(:user) { FactoryBot.create :user }
  # let(:requesting_object) do
  #   object = FactoryBot.build :web_object, user_id: user.id
  #   object.save
  #   object
  # end

  # describe 'create' do
  #   context 'with valid package' do
  #     it 'should return ok status' do
  #       time = Time.now.to_i

  #       @request.env['HTTP_X_SECONDLIFE_OWNER_KEY'] = user.avatar_key
  #       @request.env['HTTP_X_SECONDLIFE_REGION'] = requesting_object.region
  #       @request.env['HTTP_X_SECONDLIFE_LOCAL_POSITION'] = "(173.009827, 75.551231, 60.950001)"
  #       @request.env['HTTP_X_AUTH_TIME'] = time
  #       @request.env['HTTP_X_AUTH_DIGEST'] = Digest::SHA1.hexdigest(
  #         time.to_s + Settings.default.web_object.api_key
  #       )
  #       @request.env['HTTP_X_SECONDLIFE_OBJECT_KEY'] = SecureRandom.uuid
  #       post :create, params: {url: requesting_object.url}.to_json
  #       expect(response.status).to eq 201
  #     end

  #   end
  # end
end
