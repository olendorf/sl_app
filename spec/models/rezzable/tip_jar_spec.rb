# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::TipJar, type: :model do
  it { should respond_to :abstract_web_object }
  
  it_behaves_like 'it is a transactable', :tip_jar
  
  it { should have_many(:sessions) }
  
  it { should have_many(:listable_avatars) }

  it {
    should define_enum_for(:access_mode).with_values(
      access_mode_all: 0,
      access_mode_group: 1,
      access_mode_list: 2
    )
  }
  
  let(:user) { FactoryBot.create :active_user }
  let(:tip_jar) { FactoryBot.create :tip_jar }
  
  describe '#allowed_list' do 
    it 'should return the allowed list' do 
      3.times do 
        tip_jar.listable_avatars << FactoryBot.build(:allowed_avatar)
      end
      expect(tip_jar.allowed_list.size).to eq 3
    end
  end
  
  describe '#current_session' do
    before(:each) do
      tip_jar.sessions << FactoryBot.build(:session, created_at: 3.days.ago,
                                                     stopped_at: 3.days.ago + 1.hour,
                                                     duration: 1.hour.to_i)
      tip_jar.sessions << FactoryBot.build(:session, created_at: 2.days.ago,
                                                     stopped_at: 2.days.ago + 1.hour,
                                                     duration: 1.hour.to_i)
    end
    context 'when there is a current session' do 
      it 'should return the session' do 
        session = FactoryBot.build(:session, created_at: 1.hour.ago)
        tip_jar.sessions << session
        expect(tip_jar.current_session.avatar_key).to eq session.avatar_key
      end
    end
    
    context 'when there is no current session' do 
      it 'should return nil' do 
        expect(tip_jar.current_session).to be_nil
      end
    end
  end
  
end
