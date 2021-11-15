require 'rails_helper'

RSpec.describe "Api::V1::ServiceTickets", type: :request do
  let(:owner) { FactoryBot.create :owner }
  let(:terminal) { FactoryBot.create :terminal, user_id: owner.id }
  let(:avatar) { FactoryBot.create :avatar }
  
  before(:each) do 
    3.times do 
      owner.service_tickets << FactoryBot.create(:service_ticket)
    end
    2.times do 
      owner.service_tickets << FactoryBot.create(:open_ticket, client_key: avatar.avatar_key, 
                                                               client_name: avatar.avatar_name)
    end 
    4.times do 
      owner.service_tickets << FactoryBot.create(:closed_ticket, client_key: avatar.avatar_key, 
                                                                 client_name: avatar.avatar_name)
    end
  end
  
  describe "GET /index" do
    it 'should return OK status' do 
      get api_service_tickets_path, params: {avatar_key: avatar.avatar_key}, 
                                    headers: headers(terminal)
      expect(response.status).to eq 200
    end
    
    it 'should return the users open tickets' do 
      get api_service_tickets_path, params: {avatar_key: avatar.avatar_key}, 
                                    headers: headers(terminal)
      expect(JSON.parse(response.body)['data'].size).to eq 2
    end
  end
  
  describe "GET /ticket" do 
    it 'should return OK status' do 
      ticket = ServiceTicket.where(client_key: avatar.avatar_key).first
      get api_service_ticket_path(ticket), params: {avatar_key: avatar.avatar_key}, 
                                    headers: headers(terminal)
      expect(response.status).to eq 200
    end
    it 'should return the users open tickets' do 
      ticket = ServiceTicket.where(client_key: avatar.avatar_key).first
      get api_service_ticket_path(ticket), params: {avatar_key: avatar.avatar_key}, 
                                    headers: headers(terminal)
      expect(JSON.parse(response.body)['message']).to include(
        ticket.created_at.to_formatted_s(:long),
        ticket.status,
        ticket.description
        )
    end
    
    it 'should display the comments' do 
      ticket = ServiceTicket.where(client_key: avatar.avatar_key).first
      ticket.comments << Comment.new(author: avatar.avatar_name, text: "Foo")
      ticket.comments << Comment.new(author: owner.avatar_name, text: "bar")
      
      get api_service_ticket_path(ticket), params: {avatar_key: avatar.avatar_key}, 
                                    headers: headers(terminal)
      expect(JSON.parse(response.body)['message']).to include(
        ticket.created_at.to_formatted_s(:long),
        ticket.status,
        ticket.comments.first.text,
        ticket.comments.second.author
        )
    end
  end
  
  #trigger travis
  describe "UPDATE add a comment" do 
    context 'adding a comment' do 
      it 'should return OK status' do 
        ticket = ServiceTicket.where(client_key: avatar.avatar_key).first
        put api_service_ticket_path(ticket), 
                    params: {avatar_key: avatar.avatar_key}, 
                    headers: headers(terminal)
        expect(response.status).to eq 200
      end
      
      
      it 'should add the comment' do 
        ticket = ServiceTicket.where(client_key: avatar.avatar_key).first
        put api_service_ticket_path(ticket), 
                    params: {
                      avatar_name: avatar.avatar_name,
                      avatar_key: avatar.avatar_key,
                      comment_text: "foo bar"
                    }, 
                    headers: headers(terminal)
        expect(ticket.comments.size).to eq 1
      end
    end 
    
    context 'closing a ticket' do 
      it 'should return OK status' do 
        ticket = ServiceTicket.where(client_key: avatar.avatar_key).first
        put api_service_ticket_path(ticket), 
                    params: {status: 'closed', avatar_key: avatar.avatar_key}, 
                    headers: headers(terminal)
        expect(response.status).to eq 200
      end 
      
      it 'should close the ticket' do 
        ticket = ServiceTicket.where(client_key: avatar.avatar_key).first
        put api_service_ticket_path(ticket), 
                    params: {status: 'closed', avatar_key: avatar.avatar_key}, 
                    headers: headers(terminal)
        expect(ticket.reload.status).to eq 'closed'
      end
    end
  end
  
  describe "CREATE" do 
    let(:params) { {
      title: 'Service Ticket',
      description: 'some words',
      client_key: avatar.avatar_key,
      client_name: avatar.avatar_name
    } }
    
    it 'should return created status' do
      post api_service_tickets_path, params: params, 
                                    headers: headers(terminal)
      expect(response.status).to eq 201
    end
    
    it 'should create the ticket' do 
      expect{
        post api_service_tickets_path, params: params, 
                                    headers: headers(terminal)
      }.to change{owner.service_tickets.count}.by(1)
    end
  end
end
