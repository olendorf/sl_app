# frozen_string_literal: true

RSpec.shared_examples 'it has an owner api' do |model_name|
  model_name = model_name.to_sym
  let(:owner) { FactoryBot.create :owner }
  let(:user) { FactoryBot.create :active_user }
  let(:klass) { "Rezzable::#{model_name.to_s.classify}".constantize }
  
  describe "creating a new #{model_name}" do 
    let(:path) { send("api_rezzable_#{model_name.to_s.pluralize}_path") }
    
    context 'as owner' do 
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
        expect{
          post path, params: atts.to_json,
                     headers: headers(
                       web_object, api_key: Settings.default.web_object.api_key
                     )
        }.to change{ klass.count }.by(1)
      end
      
      it 'should return a nice message' do 
        post path, params: atts.to_json,
                   headers: headers(
                     web_object, api_key: Settings.default.web_object.api_key
                   )
        expect(
          JSON.parse(response.body)['message']
        ).to eq "This object has been registered in the database."
      end
      
      it 'should return the api key' do
        post path, params: atts.to_json,
                   headers: headers(
                     web_object, api_key: Settings.default.web_object.api_key
                   )
        expect(
          JSON.parse(response.body)['data']['api_key']
        ).to match(@uuid_regex)
      end
    end
    
    context 'as active user' do
      let(:web_object) do
        FactoryBot.build model_name, user_id: user.id
      end
      let(:atts) { { url: web_object.url } }

      it 'should return forbidden status' do
        post path, params: atts.to_json,
                   headers: headers(
                     web_object, api_key: Settings.default.web_object.api_key
                   )
        expect(response.status).to eq 403
      end
      
      it 'should not create an object' do 
        expect{
          post path, params: atts.to_json,
                     headers: headers(
                       web_object, api_key: Settings.default.web_object.api_key
                     )
        }.to_not change{ AbstractWebObject.count }
      end
    end
  end
  
  describe "updating a #{model_name}" do 
    let(:path) { send("api_rezzable_#{model_name.to_s.pluralize}_path") }
    let(:web_object) do
      object = FactoryBot.build model_name, user_id: owner.id
      object.save
      object
    end
    let(:atts) { { url: 'example.com' } }
    
    context 'as owner' do
    
      it 'should return ok status' do 
        post path, params: atts.to_json,
                   headers: headers(
                     web_object, api_key: Settings.default.web_object.api_key
                   )
        expect(response.status).to eq 200
      end
      
      it 'should not change the object count' do
        existing_object = FactoryBot.build model_name, user_id: owner.id
        existing_object.save
        expect{
          post path, params: atts.to_json,
                     headers: headers(
                       existing_object, api_key: Settings.default.web_object.api_key
                     )
        }.to_not change{ AbstractWebObject.count }
      end
      
      it 'should return a nice message' do 
        post path, params: atts.to_json,
                   headers: headers(
                     web_object, api_key: Settings.default.web_object.api_key
                   )
        expect(
          JSON.parse(response.body)['message']
        ).to eq "This object has been updated."
      end
    end
    
    context 'as active user' do
      it 'should return forbidden status' do 
        web_object.user_id = user.id
        web_object.save
        post path, params: atts.to_json,
                   headers: headers(
                     web_object, api_key: Settings.default.web_object.api_key
                   )
        expect(response.status).to eq 403
      end
      
      it 'should not change the object' do 
        web_object.user_id = user.id
        web_object.save
        old_url = web_object.url
        post path, params: atts.to_json,
                   headers: headers(
                     web_object, api_key: Settings.default.web_object.api_key
                   )
        expect(web_object.reload.url).to eq old_url
      end
    end
  end
  
  describe 'getting object data' do 
    let(:web_object) do
      object = FactoryBot.build model_name, user_id: owner.id
      object.save
      object
    end
    let(:path) { send("api_rezzable_#{model_name.to_s}_path", web_object.object_key) }
    
    context 'as an owner' do 
      
      it 'should return OK status' do
        get path, headers: headers(web_object, api_key: web_object.api_key)
        expect(response.status).to eq 200
      end
      
      it 'should send data' do 
        get path, headers: headers(web_object, api_key: web_object.api_key)
        expect(JSON.parse(response.body)).to have_key('data')
      end
    end
    
    context 'as an active user' do 
      it 'should return forbidden status' do 
        web_object.user_id = user.id
        web_object.save
        get path, headers: headers(web_object, api_key: web_object.api_key)
        expect(response.status).to eq 403
      end
    end
  end
  
  describe 'deleting an object' do 
    let(:web_object) do
      object = FactoryBot.build model_name, user_id: owner.id
      object.save
      object
    end
    let(:path) { send("api_rezzable_#{model_name}_path", web_object.object_key) }
    
    context 'as an owner' do
      it 'should return ok status' do 
        delete path, headers: headers(web_object)
        expect(response.status).to eq 200
      end
      
      it 'should delete the object' do 
        delete path, headers: headers(web_object)
        expect(AbstractWebObject.find_by_object_key(web_object.object_key)).to be_nil
      end
      
      it 'should return a nice message' do 
        delete path, headers: headers(web_object)
        expect(JSON.parse(response.body)['message']).to eq (
          "This object has been deleted."
        )
      end
    end
    
    context 'as a user' do 
      it 'should return forbidden status' do 
        web_object.user_id = user.id
        web_object.save
        delete path, headers: headers(web_object)
        expect(response.status).to eq 403
      end
      
      it 'should not delete an object' do 
        web_object.user_id = user.id
        web_object.save
        
        expect{
          delete path, headers: headers(web_object)
        }.to_not change{ AbstractWebObject.count }
      end
    end
  end
end