# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::Server, type: :model do
  it { should respond_to :abstract_web_object }
  it { should have_many(:clients).class_name('AbstractWebObject').dependent(:nullify) }
  it { should have_many(:inventories).class_name('Analyzable::Inventory').dependent(:destroy) }
  
  describe 'adding inventory' do 
    
    let(:user) { FactoryBot.create :active_user }
    let(:server) { FactoryBot.create :server, user_id: user.id }
    it 'should set the user too' do 
      server.inventories << FactoryBot.build(:inventory)
      expect(server.inventories.first.user_id).to eq user.id
    end
  end
end
