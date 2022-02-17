# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Analyzable::EmployeesController', type: :request do
  let(:user) { FactoryBot.create :active_user }
  let(:time_cop) { FactoryBot.create :time_cop, user_id: user.id }
  
  describe 'create' do 
    let(:path) { api_analyzable_employees_path }
    let(:avatar) { FactoryBot.create :avatar }
    let(:hourly_pay) { 400 }
    let(:max_hours) { 40 }      
    let(:atts) { {
        avatar_name: avatar.avatar_name,
        avatar_key: avatar.avatar_key,
        hourly_pay: hourly_pay,
        max_hours: max_hours
      } }
    
    context 'avatar not an employee' do 

      it 'should return created status' do 
        post path, params: atts.to_json, headers: headers(time_cop)
        expect(response.status).to eq 201
      end
      
      it 'should create a user' do 
        expect{
          post path, params: atts.to_json, headers: headers(time_cop)
        }.to change{user.employees.count}.by(1)
      end
    end
    
    context 'avatar is already an employee' do 
      before(:each) do 
        FactoryBot.create(:employee, 
                              avatar_name: avatar.avatar_name,
                              avatar_key: avatar.avatar_key,
                              user_id: user.id)
      end
      
      it 'should return conflict status' do 
        post path, params: atts.to_json, headers: headers(time_cop)
        expect(response.status).to eq 422
      end 
      
      it 'should not create a user' do 
      
        expect{
          post path, params: atts.to_json, headers: headers(time_cop)
            }.to_not change{user.employees.count}
      end
    end
  end
  
  describe 'show' do 
    let(:employee) { FactoryBot.create :employee, user_id: user.id }
    let(:path) { api_analyzable_employee_path(employee.avatar_key) }
    
    it 'should return ok status' do 
      get path, headers: headers(time_cop)
      expect(response.status).to eq 200
    end
    
    it 'should return the correct data' do 
      get path, headers: headers(time_cop)
      expect(
        JSON.parse(response.body)['data'].with_indifferent_access
        ).to include(
          avatar_name: employee.avatar_name,
          avatar_key: employee.avatar_key,
          hourly_pay: employee.hourly_pay,
          hours_worked: 0.0,
          max_hours: employee.max_hours,
          pay_owed: 0
        )
    end
  end
  
  describe 'index' do 
    before(:each) do 
      32.times do |i|
        employee = FactoryBot.create(:employee, hourly_pay: 10, avatar_name: "Random avie#{i}", user_id: user.id)
        4.times do 
          employee.work_sessions << FactoryBot.build(:work_session, duration: 2.0, pay: 2.0 * employee.hourly_pay)
        end
      end
    end
    
    let(:path) { api_analyzable_employees_path }
    
    context 'no page sent' do 
      it 'returns ok status' do 
        get path, headers: headers(time_cop)
        expect(response.status).to eq 200
      end
      
      it 'returns the first page of data' do 
        get path, headers: headers(time_cop)
        expect(JSON.parse(response.body)['data']['employees'].size).to eq 9
      end
      
      it 'returns the total amount owed' do 
        get path, headers: headers(time_cop)
        expect(JSON.parse(response.body)['data']['total_pay']).to eq(2 * 10 * 4 * 32)
      end
    end
    
    context 'page 2 requested' do 
      it 'returns ok status' do 
        get path, params: {employee_page: 2}, headers: headers(time_cop)
        expect(response.status).to eq 200
      end
      
      it 'returns the  page of data' do 
        get path, params: {employee_page: 2}, headers: headers(time_cop)
        expect(JSON.parse(response.body)['data']['employees'].size).to eq 9
      end
    end  
    
    context 'last page  requested' do 
      it 'returns ok status' do 
        get path, params: {employee_page: 4}, headers: headers(time_cop)
        expect(response.status).to eq 200
      end
      
      it 'returns the first page of data' do 
        get path, params: {employee_page: 4}, headers: headers(time_cop)
        expect(JSON.parse(response.body)['data']['employees'].size).to eq 5
      end
    end
  end
  
  describe 'update' do 
    let(:employee) { FactoryBot.create :employee, user_id: user.id }
    let(:path) { api_analyzable_employee_path(employee.avatar_key) }
    
    let(:atts) { {max_hours: 60, hourly_pay: 10000} }
    
    it 'should return OK status' do 
      put path, params: atts.to_json, headers: headers(time_cop)
      expect(response.status).to eq 200
    end
    
    it 'should update the employee' do
      put path, params: atts.to_json, headers: headers(time_cop)
      expect(employee.reload.attributes).to include(
          'max_hours' => 60,
          'hourly_pay' => 10000
        )
    end
  end
  
  describe 'delete' do 
    let(:employee) { FactoryBot.create :employee, user_id: user.id }
    let(:path) { api_analyzable_employee_path(employee.avatar_key) }
    
    before(:each) { employee }
    
    it 'should return ok status' do 
      delete path, headers: headers(time_cop)
      expect(response.status).to eq 200
    end
    
    it 'should delete the employee' do 
      expect{
        delete path, headers: headers(time_cop)
      }.to change{user.employees.count}.by(-1)
    end
    
  end
  
  describe 'clocking in and out' do 
    let(:employee) { FactoryBot.create :employee, user_id: time_cop.user.id }
    let(:atts) { {
      work_session:  true 
    } }
    let(:path) { api_analyzable_employee_path(employee.avatar_key)}
    let(:non_employee_path) { api_analyzable_employee_path(SecureRandom.uuid) }
    
    context 'user is logging in' do 
      context 'avatar is an employee' do
        it 'should return ok status' do 
          put path, params: atts.to_json, headers: headers(time_cop)
          expect(response.status).to eq 200
        end
        
        it 'should create an open a work sesson' do 
          expect{
            put path, params: atts.to_json, headers: headers(time_cop)
          }.to change{employee.work_sessions.count}.by(1)
        end
        
        it 'should send the correct message' do 
          put path, params: atts.to_json, headers: headers(time_cop)
          expect(JSON.parse(response.body)['message']).to eq 'You are clocked in.'
        end
      end 
      
      context 'avatar is not an employee' do
        it 'should return not found status' do 
          put non_employee_path, params: atts.to_json, headers: headers(time_cop)
          expect(response.status).to eq 404
        end
        
        it 'should not create a work sesson' do 
          expect{
            put non_employee_path, params: atts.to_json, headers: headers(time_cop)
          }.to_not change{employee.work_sessions.count}
        end
        
        it 'should return the correct message' do 
          put non_employee_path, params: atts.to_json, headers: headers(time_cop)
          expect(JSON.parse(response.body)['message']).to eq 'You are not an employee here.'
        end
      end
    end
    
    context 'user is logging out' do 
      before(:each) do 
        employee.update(work_session: true)
        employee.reload.work_sessions.last.update(created_at: 2.hours.ago)
      end
      
      it 'should return ok status' do 
        put path, params: atts.to_json, headers: headers(time_cop)
        expect(response.status).to eq 200
      end
      
      it 'should not create a work session' do 
          expect{
            put path, params: atts.to_json, headers: headers(time_cop)
          }.to_not change{employee.work_sessions.count}
      end
      
      it 'should set the data correctly' do 
        put path, params: atts.to_json, headers: headers(time_cop)
        expect(
          employee.work_sessions.last.stop_time
          ).to be_within(30.seconds).of(Time.current)
        expect(
          employee.work_sessions.last.duration
          ).to be_within(0.1).of(2.0)
        expect(
          employee.work_sessions.last.pay
          ).to be_within(1).of(2.0 * employee.hourly_pay)
      end
    end
  end
  
  describe 'paying employees' do 
    
    context 'paying one employee' do 
      
      let(:uri_regex) do 
        %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/pay_user\?
           auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
      end
      
      let(:reg_str) { '{|"avatar_name\":\".*,\"avatar_key\":.*\",\"amount":"80"}' }
      
      let(:employee) { FactoryBot.create(:employee, hourly_pay: 10, user_id: user.id) }
      before(:each) do 
        4.times do 
          employee.work_sessions << FactoryBot.build(:work_session, duration: 2.0, pay: 2.0 * employee.hourly_pay)
        end
        employee.update_columns(pay_owed: 80, hours_worked: 8)
        
        
        3.times do 
          user.web_objects << FactoryBot.build(:server)
        end 
        
        
        @stub = stub_request(:put, uri_regex)
              .with(body: /#{reg_str}/)
      end
      
      let(:path) {  pay_api_analyzable_employee_path(employee.avatar_key) }

      
      it 'should return ok status' do       
        put path, headers: headers(time_cop)
        expect(response.status).to eq 200
      end
      
      it 'should set the hours to zero' do 
        put path, headers: headers(time_cop)
        expect(employee.reload.hours_worked).to eq 0
      end
      
      it 'should set the pay_owed to zero' do 
        put path, headers: headers(time_cop)
        expect(employee.reload.pay_owed).to eq 0
      end
      
      # it 'should pay the employee' do 
      #   put path, headers: headers(time_cop)
      #   expect(@stub).to have_been_requested
      # end
      
      it 'should create a transaction' do 
        expect{
          put path, headers: headers(time_cop)
        }.to change{user.transactions.count}.by(1)
      end
    end 
    
    
    context 'pay all employees' do  
      
      
        
      let(:uri_regex) do 
        %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/pay_user\?
           auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
      end
      
      let(:reg_str) { '{|"avatar_name\":\".*,\"avatar_key\":.*\",\"amount":"80"}' }
      
      
      let(:path) {  pay_all_api_analyzable_employees_path }
    
      before(:each) do 
        4.times do |i|
          employee = FactoryBot.create(:employee, hourly_pay: 10, avatar_name: "Random avie#{i}", user_id: user.id)
          4.times do 
            employee.work_sessions << FactoryBot.build(:work_session, duration: 2.0, pay: 2.0 * employee.hourly_pay)
          end
          employee.update_columns(pay_owed: 80, hours_worked: 8)
        end
        
        3.times do 
          user.web_objects << FactoryBot.build(:server)
        end 
        
        @stub = stub_request(:put, uri_regex)
              .with(body: /#{reg_str}/)
      end
      
      it 'should return ok status' do       
        put path, headers: headers(time_cop)
        expect(response.status).to eq 200
      end
      
      # it 'should pay the employee' do 
      #   put path, headers: headers(time_cop)
      #   expect(@stub).to have_been_requested.times(4)
      # end
      
      it 'should create a transaction' do 
        expect{
          put path, headers: headers(time_cop)
        }.to change{user.transactions.count}.by(4)
      end

    end
  end
 
end
