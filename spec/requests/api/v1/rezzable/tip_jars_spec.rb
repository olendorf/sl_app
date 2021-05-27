require 'rails_helper'

RSpec.describe "Api::V1::Rezzable::TipJars", type: :request do
  it_behaves_like 'a user object API', :tip_jar
  
  describe 'tip jar sessions' do 
    let(:user) { FactoryBot.create :active_user }
    let(:tip_jar) { FactoryBot.create :tip_jar, user_id: user.id }
    let(:avatar) { FactoryBot.build :avatar }
    let(:path) { api_rezzable_tip_jar_path(tip_jar) }
    context 'user logs in' do 
      let(:atts) {{
        session: {
          avatar_name: avatar.avatar_name,
          avatar_key: avatar.avatar_key
        }
      }}
      context 'access mode all' do 
        it 'should return ok status' do 
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(response.status).to eq 200
        end
        
        it 'should add the current session' do 
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.sessions.size).to eq 1
        end
        
        it 'should be the correct session' do 
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.current_session.avatar_key).to eq avatar.avatar_key
        end
        
      end 
      
      # Has to be handles in world, so the same
      context 'access mode group' do 
        before(:each) { tip_jar.update(access_mode: :access_mode_group) }
        it 'should return ok status' do 
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(response.status).to eq 200
        end
        
        it 'should add the current session' do 
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.sessions.size).to eq 1
        end
        
        it 'should be the correct session' do 
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.current_session.avatar_key).to eq avatar.avatar_key
        end
        
      end 
      
      context 'access mode list' do 
        before(:each) do 
          tip_jar.update(access_mode: :access_mode_list)
        end
        context 'user is not on list' do 
          it 'should return forbidden status' do 
            put path, params: atts.to_json, headers: headers(tip_jar)
            expect(response.status).to eq 403
          end
        end
      end
    end
    
    describe 'user logs out' do 
      let(:atts) {{
        session: {
          avatar_name: nil,
          avatar_key: nil
        }
      }}
      
      before(:each) do 
        tip_jar.sessions << FactoryBot.build(:session, avatar_name: avatar.avatar_name, 
                                                       avatar_key: avatar.avatar_key)
      end
      
      it 'should return ok status' do 
        put path, params: atts.to_json, headers: headers(tip_jar)
        expect(response.status).to eq 200
      end
      
      it 'should close the session' do 
        put path, params: atts.to_json, headers: headers(tip_jar)
        expect(tip_jar.current_session).to be_nil
      end
      
    end
    
    describe 'handling tips' do 
      # let(:tipper)
      # let(:atts) {{ 
      #   tip: {
      #     amount: 100,
          
      #   }
      # }}
      
      # # this shouldn't happen but...
      # context 'no user logged in' do 
        
      # end 
      
      # context 'user is logged in' do 
      # end
    end
  end
end