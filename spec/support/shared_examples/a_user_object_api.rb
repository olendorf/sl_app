# frozen_string_literal: true

RSpec.shared_examples 'a user object API' do |model_name|
  let(:owner) { FactoryBot.create :owner }
  let(:user) { FactoryBot.create :active_user }
  let(:klass) { "Rezzable::#{model_name.to_s.classify}".constantize }

  describe "creating a #{model_name}" do
    let(:path) { send("api_rezzable_#{model_name.to_s.pluralize}_path") }

    context 'as an owner' do
      let(:web_object) do
        FactoryBot.build model_name, user_id: owner.id
      end
      let(:atts) { { url: web_object.url } }

      it 'should return created status' do
        post path, params: atts.to_json,
                  headers: headers(
                    web_object, api_key: Settings.default.web_object.api_key
                  )
        expect(response.status).to eq 201
      end

      it "should create a #{model_name}" do
        expect do
          post path, params: atts.to_json,
                    headers: headers(
                      web_object, api_key: Settings.default.web_object.api_key
                    )
        end.to change(klass, :count).by(1)
      end

      it 'should add the owner' do
        post path, params: atts.to_json,
                  headers: headers(
                    web_object, api_key: Settings.default.web_object.api_key
                  )
        expect(AbstractWebObject.last.user.id).to eq owner.id
      end

      it 'returns a nice message do ' do
        post path, params: atts.to_json,
                  headers: headers(
                    web_object, api_key: Settings.default.web_object.api_key
                  )
        expect(
          JSON.parse(response.body)['message']
        ).to eq('This object has been registered in the database.')
      end

      it 'returns the data' do
        post path, params: atts.to_json,
                  headers: headers(web_object,
                                    api_key: Settings.default.web_object.api_key)
        puts "class api key: #{klass.last.api_key}"
        expect(JSON.parse(response.body)['data']).to include(
          'api_key' => klass.last.api_key
        )
      end
    end

    context 'as a user' do
      let(:web_object) do
        FactoryBot.build model_name, user_id: user.id
      end
      let(:atts) { { url: web_object.url } }

      it 'should return the correct status status' do
        post path, params: atts.to_json,
                  headers: headers(web_object,
                                    api_key: Settings.default.web_object.api_key)
        expect(response.status).to eq 201
      end
    end

    context 'when the object exists' do
      let(:existing_object) {
        web_object = FactoryBot.build model_name, user_id: user.id
        web_object.save
        web_object
      }

      let(:new_object) do
        FactoryBot.build model_name, user_id: user.id,
                                    object_name: existing_object.object_name,
                                    object_key: existing_object.object_key
      end
      let(:atts) { { url: new_object.url } }

      it 'should return ok status' do
        post path, params: atts.to_json,
                  headers: headers(new_object,
                                    api_key: Settings.default.web_object.api_key)

        expect(response.status).to eq 200
      end
    end

    context 'user does not exist' do
      let(:web_object) do
        FactoryBot.build model_name
      end
      let(:atts) { { url: web_object.url } }

      it 'should return not found status' do
        post path, params: atts.to_json,
                  headers: headers(
                    web_object, avatar_key: SecureRandom.uuid,
                                api_key: Settings.default.web_object.api_key
                  )
        expect(response.status).to eq 404
      end
    end
  end

  describe "showing #{model_name} data" do
    let(:path) { send("api_rezzable_#{model_name}_path", web_object.object_key) }

    context 'user exists' do
      let(:web_object) {
        web_object = FactoryBot.build model_name, user_id: owner.id
        web_object.save
        web_object
      }
      before(:each) { get path, headers: headers(web_object) }
      it 'should return OK status' do
        expect(response.status).to eq 200
      end

      it 'should return the data' do
        web_object.reload
        puts "api key at get: #{web_object.api_key}"
        expect(JSON.parse(response.body)['data']).to include(
          'api_key' => web_object.api_key
        )
      end
    end

    context 'user does not exists' do
      let(:web_object) {
        web_object = FactoryBot.build model_name
        web_object.save
        web_object
      }
      it 'should return NOT FOUND status' do
        get path, headers: headers(web_object, avatar_key: SecureRandom.uuid)
        expect(response.status).to eq 404
      end
    end
  end

  describe "updating a #{model_name}" do
    let(:path) { send("api_rezzable_#{model_name}_path", web_object.object_key) }
    context 'owner exists' do
      let(:web_object) {
        web_object = FactoryBot.build model_name, user_id: owner.id
        web_object.save
        web_object
      }
      let(:old_url) { web_object.url }
      context 'valid data' do
        let(:atts) { { description: 'some new idea', url: 'http://example.com' } }
        before(:each) { put path, params: atts.to_json, headers: headers(web_object) }
        it 'returns OK status' do
          expect(response.status).to eq 200
        end

        it 'returns a nice message' do
          expect(
            JSON.parse(response.body)['message']
          ).to eq 'This object has been updated.'
        end

        it "updates the #{model_name}" do
          web_object.reload
          expect(web_object.description).to eq atts[:description]
        end
      end

      context 'invalid data' do
        let(:atts) { { description: 'some new idea', url: '' } }
        before(:each) { put path, params: atts.to_json, headers: headers(web_object) }
        it 'returns BAD REQUEST status' do
          expect(response.status).to eq 422
        end

        it 'returns a helpful message' do
          expect(
            JSON.parse(response.body)['message']
          ).to eq "Validation failed: Url can't be blank"
        end

        it 'should not change the object' do
          expect(web_object.url).to eq old_url
        end
      end
    end

    context 'user does not exist' do
      let(:web_object) {
        web_object = FactoryBot.build model_name
        web_object.save
        web_object
      }
      let(:atts) { { description: 'some new idea', url: 'http://example.com' } }
      it 'should return NOT FOUND status' do
        get path, params: atts.to_json,
                  headers: headers(web_object, avatar_key: SecureRandom.uuid)
        expect(response.status).to eq 404
      end
    end
  end

  describe 'destroying' do
    let(:web_object) {
      web_object = FactoryBot.build model_name, user_id: owner.id
      web_object.save
      web_object
    }
    let(:path) { send("api_rezzable_#{model_name}_path", web_object.object_key) }

    it 'should return OK status' do
      delete path, headers: headers(web_object)
      expect(response.status).to eq 200
    end

    it 'should return a nice message' do
      delete path, headers: headers(web_object)
      expect(
        JSON.parse(response.body)['message']
      ).to eq 'This object has been deleted.'
    end

    it 'should delete the object' do
      web_object.touch
      expect do
        delete path, headers: headers(web_object)
      end.to change(klass, :count).by(-1)
    end
  end
end
