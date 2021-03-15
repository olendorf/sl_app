# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerSlRequest do
  let(:user) { FactoryBot.create :active_user }
  
  let(:server) { FactoryBot.create :server, user_id: user.id }
  
  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end
  
  describe '.send_money' do 
    it 'should make a request' do 
      
      stub = stub_request(:post, uri_regex).
             with(body: '{"avatar_name":"Random Citizen","amount":100}')
      
      ServerSlRequest.send_money(server, "Random Citizen", 100)
              
      
      expect(stub).to have_been_requested
    end
    
    
    context 'there is an error' do 
      it 'should raise an error' do
        stub_request(:post, uri_regex).
               with(body: '{"avatar_name":"Random Citizen","amount":100}').
               to_return(status: 400, body: 'foo')
               
        expect{
          ServerSlRequest.send_money(server, "Random Citizen", 100)
        }.to raise_error(RestClient::ExceptionWithResponse)
      end
             
    end
    
  end
end