# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceTicket, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :client_key }
  it { should belong_to :user }
  it { should have_many :comments }

  it do
    should define_enum_for(:status)
      .with_values(closed: 0, open: 1)
  end

  describe :close! do
    it 'shouild close the ticket' do
      ticket = FactoryBot.create :open_ticket
      ticket.close!
      expect(ticket.status).to eq 'closed'
    end
  end
end
