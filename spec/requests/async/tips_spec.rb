require 'rails_helper'

RSpec.describe "Async::Tips", type: :request do
  describe "GET /index" do
    let(:user) { FactoryBot.create :active_user }
    
    before(:each) do 
      FactoryBot.create :tip_jar, user_id: user.id
      FactoryBot.create :tip_jar, user_id: user.id
      avatars = FactoryBot.create_list(:avatar, 5)
      tippers = FactoryBot.create_list(:avatar, 10)
      10.times do
        tip_jar = user.reload.tip_jars.sample
        employee = avatars.sample
        tip_jar.sessions << FactoryBot.build(:session, avatar_name: employee.avatar_name, 
                                                       avatar_key: employee.avatar_key,
                                                       user_id: user.id)
        20.times do 
          tipper = tippers.sample
          FactoryBot.create(:tip, target_name: tipper.avatar_name,
                                  target_key: tipper.avatar_key,
                                  user_id: user.id,
                                  session_id: tip_jar.sessions.last.id,
                                  transactable_id: tip_jar.id, 
                                  transactable_type: 'Rezzable::TipJar')
                  
        end
        
        sign_in user
      end
    end
    
    let(:path) { async_tips_path }
  
    context 'asking for tips histogram data' do
      it 'should return ok status' do 
        get path, params: { chart: 'tips_histogram' }
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: { chart: 'tips_histogram' }
        expect(JSON.parse(response.body).size).to eq 200
      end
    end
    
    context 'asking for tippers histogram data' do
      it 'should return ok status' do 
        get path, params: { chart: 'tippers_histogram' }
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: { chart: 'tippers_histogram' }
        expect(JSON.parse(response.body).size).to eq 10
      end
    end
    
        
    context 'asking for sessions histogram data' do
      it 'should return ok status' do 
        get path, params: { chart: 'sessions_histogram' }
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: { chart: 'sessions_histogram' }
        expect(JSON.parse(response.body).size).to eq 10
      end
    end
    
    context 'asking for employee time histogram data' do
      it 'should return ok status' do 
        get path, params: { chart: 'employee_time_histogram' }
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: { chart: 'employee_time_histogram' }
        expect(JSON.parse(response.body).size).to be > 0
      end
    end
    
    context 'asking for employee tip counts histogram data' do
      it 'should return ok status' do 
        get path, params: { chart: 'employee_tip_counts_histogram' }
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: { chart: 'employee_tip_counts_histogram' }
        expect(JSON.parse(response.body).size).to be > 0
      end
    end
    
    context 'asking for employee tip totals histogram data' do
      it 'should return ok status' do 
        get path, params: { chart: 'employee_tip_totals_histogram' }
        expect(response.status).to eq 200
      end
      
      it 'should return the data' do 
        get path, params: { chart: 'employee_tip_totals_histogram' }
        expect(JSON.parse(response.body).size).to be > 0
      end
    end
  end
  

end
