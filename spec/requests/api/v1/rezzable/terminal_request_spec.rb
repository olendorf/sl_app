# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::Terminals', type: :request do
  it_behaves_like 'it has an owner api', :terminal

  # let(:owner) { FactoryBot.create :owner }
  # let(:user) { FactoryBot.create :active_user }

  # describe 'creating a new terminal' do
  #   let(:path) { api_rezzable_terminals_path }

  #   context 'as owner' do
  #     let(:web_object) do
  #       FactoryBot.build :terminal, user_id: owner.id
  #     end
  #     let(:atts) { { url: web_object.url } }

  #     it 'should return created status' do
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(response.status).to eq 201
  #     end

  #     it 'should create a web object' do
  #       expect{
  #         post path, params: atts.to_json,
  #                   headers: headers(
  #                     web_object, api_key: Settings.default.web_object.api_key
  #                   )
  #       }.to change{ AbstractWebObject.count }.by(1)
  #     end

  #     it 'should return a nice message' do
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(
  #         JSON.parse(response.body)['message']
  #       ).to eq "This object has been registered in the database."
  #     end

  #     it 'should return the api key' do
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(
  #         JSON.parse(response.body)['data']['api_key']
  #       ).to match(@uuid_regex)
  #     end
  #   end

  #   context 'as active user' do
  #     let(:web_object) do
  #       FactoryBot.build :terminal, user_id: user.id
  #     end
  #     let(:atts) { { url: web_object.url } }

  #     it 'should return forbidden status' do
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(response.status).to eq 403
  #     end

  #     it 'should not create an object' do
  #       expect{
  #         post path, params: atts.to_json,
  #                   headers: headers(
  #                     web_object, api_key: Settings.default.web_object.api_key
  #                   )
  #       }.to_not change{ AbstractWebObject.count }
  #     end
  #   end
  # end

  # describe 'updating a terminal' do
  #   let(:path) { api_rezzable_terminals_path }
  #   let(:web_object) do
  #     object = FactoryBot.build :terminal, user_id: owner.id
  #     object.save
  #     object
  #   end
  #   let(:atts) { { url: 'example.com' } }

  #   context 'as owner' do

  #     it 'should return ok status' do
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(response.status).to eq 200
  #     end

  #     it 'should not change the object count' do
  #       existing_object = FactoryBot.build :terminal, user_id: owner.id
  #       existing_object.save
  #       expect{
  #         post path, params: atts.to_json,
  #                   headers: headers(
  #                     existing_object, api_key: Settings.default.web_object.api_key
  #                   )
  #       }.to_not change{ AbstractWebObject.count }
  #     end

  #     it 'should return a nice message' do
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(
  #         JSON.parse(response.body)['message']
  #       ).to eq "This object has been updated."
  #     end
  #   end

  #   context 'as active user' do
  #     it 'should return forbidden status' do
  #       web_object.user_id = user.id
  #       web_object.save
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(response.status).to eq 403
  #     end

  #     it 'should not change the object' do
  #       web_object.user_id = user.id
  #       web_object.save
  #       old_url = web_object.url
  #       post path, params: atts.to_json,
  #                 headers: headers(
  #                   web_object, api_key: Settings.default.web_object.api_key
  #                 )
  #       expect(web_object.reload.url).to eq old_url
  #     end
  #   end
  # end

  # describe 'getting object data' do
  #   let(:web_object) do
  #     object = FactoryBot.build :terminal, user_id: owner.id
  #     object.save
  #     object
  #   end
  #   let(:path) { api_rezzable_terminal_path(web_object.object_key) }

  #   context 'as an owner' do

  #     it 'should return OK status' do
  #       get path, headers: headers(web_object, api_key: web_object.api_key)
  #       expect(response.status).to eq 200
  #     end

  #     it 'should send data' do
  #       get path, headers: headers(web_object, api_key: web_object.api_key)
  #       expect(JSON.parse(response.body)).to have_key('data')
  #     end
  #   end

  #   context 'as an active user' do
  #     it 'should return forbidden status' do
  #       web_object.user_id = user.id
  #       web_object.save
  #       get path, headers: headers(web_object, api_key: web_object.api_key)
  #       expect(response.status).to eq 403
  #     end
  #   end
  # end

  # describe 'deleting an object' do
  #   let(:web_object) do
  #     object = FactoryBot.build :terminal, user_id: owner.id
  #     object.save
  #     object
  #   end
  #   let(:path) { api_rezzable_terminal_path(web_object.object_key) }

  #   context 'as an owner' do
  #     it 'should return ok status' do
  #       delete path, headers: headers(web_object)
  #       expect(response.status).to eq 200
  #     end

  #     it 'should delete the object' do
  #       delete path, headers: headers(web_object)
  #       expect(AbstractWebObject.find_by_object_key(web_object.object_key)).to be_nil
  #     end

  #     it 'should return a nice message' do
  #       delete path, headers: headers(web_object)
  #       expect(JSON.parse(response.body)['message']).to eq (
  #         "This object has been deleted."
  #       )
  #     end
  #   end

  #   context 'as a user' do
  #     it 'should return forbidden status' do
  #       web_object.user_id = user.id
  #       web_object.save
  #       delete path, headers: headers(web_object)
  #       expect(response.status).to eq 403
  #     end

  #     it 'should not delete an object' do
  #       web_object.user_id = user.id
  #       web_object.save

  #       expect{
  #         delete path, headers: headers(web_object)
  #       }.to_not change{ AbstractWebObject.count }
  #     end
  #   end
  # end
end
