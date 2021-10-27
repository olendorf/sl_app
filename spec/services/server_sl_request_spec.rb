# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerSlRequest do
  let(:user) { FactoryBot.create :active_user }

  let(:server) { FactoryBot.create :server, user_id: user.id }

  describe '.send_money' do
    let(:uri_regex) do
      %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
         auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
    end
    it 'should make a request' do
      stub = stub_request(:post, uri_regex)
             .with(body: '{"avatar_name":"Random Citizen","amount":100}')

      ServerSlRequest.send_money(server, 'Random Citizen', 100)

      expect(stub).to have_been_requested
    end

    context 'there is an error' do
      it 'should raise an error' do
        stub_request(:post, uri_regex)
          .with(body: '{"avatar_name":"Random Citizen","amount":100}')
          .to_return(status: 400, body: 'foo')

        expect {
          ServerSlRequest.send_money(server, 'Random Citizen', 100)
        }.to raise_error(RestClient::ExceptionWithResponse)
      end
    end
  end

  describe '.message_user' do
    let(:owner) { FactoryBot.create :owner }

    before(:each) do
      3.times do
        owner.web_objects << FactoryBot.create(:server)
      end
    end
    
    let(:user) { FactoryBot.build :avatar }
    
    
    let(:uri_regex) do
      %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
         auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
    end
    
    it 'should send the message to the user' do 
      reg_str = '{|"avatar_name\":\".*,\"avatar_key\":.*\",\"message":"foo"}'
      
      stub = stub_request(:post, uri_regex)
               .with(body: "abcd").with(
                 body: /#{reg_str}/)
      ServerSlRequest.message_user(
        owner.servers.sample, user.avatar_name, user.avatar_key, "foo")
      expect(stub).to have_been_requested
    end

    # context 'less than three days before payment is due' do
    #   it 'should make a request' do
    #     reg_str = '"avatar_name":.*Random Citizen.*gentle ' +
    #               'reminder.*maps.secondlife.com.*'
    #     stub = stub_request(:post, uri_regex)
    #           .with(body: /#{reg_str}/)

    #     ServerSlRequest.account_payment_message('Random Citizen', SecureRandom.uuid,
    #                                             2.days.from_now)

    #     expect(stub).to have_been_requested
    #   end
    # end

    # context 'payment is less than 7 days past due' do
    #   let(:uri_regex) do
    #     %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
    #       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
    #   end
    #   it 'should make a request' do
    #     reg_str = '"avatar_name":.*Random Citizen.*' +
    #               'Your SLapp Data account expired .*maps.secondlife.com.*'
    #     stub = stub_request(:post, uri_regex)
    #           .with(body: /#{reg_str}/)

    #     ServerSlRequest.account_payment_message('Random Citizen', SecureRandom.uuid, 3.days.ago)

    #     expect(stub).to have_been_requested
    #   end
    # end

    # context 'payment is less than 7 days past due' do
    #   let(:uri_regex) do
    #     %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/
    #       [-a-f0-9]{36}/message_user\?
    #       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
    #   end
    #   it 'should make a request' do
    #     reg_str = '"avatar_name":.*Random Citizen.*inactivated soon ' +
    #               'due to nonpayment.*maps.secondlife.com.*'
    #     stub = stub_request(:post, uri_regex)
    #           .with(body: /#{reg_str}/)

    #     ServerSlRequest.account_payment_message('Random Citizen', SecureRandom.uuid, 8.days.ago)

    #     expect(stub).to have_been_requested
    #   end
    # end
    # # context 'there is an error' do
    # #   it 'should raise an error' do
    # #     stub_request(:post, uri_regex)
    # #       .with(body: '{"avatar_name":"Random Citizen","amount":100}')
    # #       .to_return(status: 400, body: 'foo')

    # #     expect {
    # #       ServerSlRequest.send_money(server, 'Random Citizen', 100)
    # #     }.to raise_error(RestClient::ExceptionWithResponse)
    # #   end
    # # end
  end
end
