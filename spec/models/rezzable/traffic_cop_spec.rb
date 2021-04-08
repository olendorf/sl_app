# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::TrafficCop, type: :model do
  it { should respond_to :abstract_web_object }

  it {
    should have_many(:visits).dependent(:destroy)
                             .class_name('Analyzable::Visit')
  }

  it { should have_many(:listable_avatars).dependent(:destroy) }

  it {
    should define_enum_for(:sensor_mode).with_values(
      sensor_mode_region: 0,
      sensor_mode_parcel: 1,
      sensor_mode_owned_parcels: 2
    )
  }

  it {
    should define_enum_for(:security_mode).with_values(
      security_mode_off: 0,
      security_mode_parcel: 1,
      security_mode_owned_parcels: 2
    )
  }
  
  it {
    should define_enum_for(:access_mode).with_values(
        access_mode_banned: 0,
        access_mode_allowed: 1
      )
  }

  let(:user) { FactoryBot.create :active_user }
  let(:traffic_cop) { FactoryBot.create :traffic_cop, user_id: user.id, 
                                                      first_visit_message: 'foo', 
                                                      repeat_visit_message: 'bar' }

  describe '#add_to_allowed_list' do
    it 'should add the listable ' do
      avatar = FactoryBot.build(:avatar)
      traffic_cop.add_to_allowed_list(avatar.avatar_name, avatar.avatar_key)
      expect(traffic_cop.listable_avatars.where(list_name: 'allowed').size).to eq 1
    end
  end

  describe '#add_to_banned_list' do
    it 'should add the listable' do
      avatar = FactoryBot.build(:avatar)
      traffic_cop.add_to_banned_list(avatar.avatar_name, avatar.avatar_key)
      expect(traffic_cop.listable_avatars.where(list_name: 'banned').size).to eq 1
    end
  end
  
  describe '#allowed_list' do 
    it 'should return only allowed avatars' do 
      traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:banned_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:banned_avatar)
      expect(traffic_cop.allowed_list.size).to eq 3
    end
  end
  
  describe '#banned_list' do 
    it 'should return only banned avatars' do 
      traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:banned_avatar)
      traffic_cop.listable_avatars << FactoryBot.build(:banned_avatar)
      expect(traffic_cop.banned_list.size).to eq 2
    end
  end
  
  
  describe 'handling detections' do 
    context 'first visit' do 
      before(:each) do 
        traffic_cop.update(detection: {
          avatar_name: 'Random Citizen',
          avatar_key: 'foo',
          position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                          transform_values { |v| v.round(4) }
        })
      end
      it 'should create a new visit' do 
        expect(traffic_cop.visits.size).to eq 1
      end
      
      it 'should have the correct start time' do 
        expect(traffic_cop.visits.first.start_time).to be_within(1.second).of(Time.now)
      end
      
      it 'should have the correct duration' do 
        expect(traffic_cop.visits.first.duration).to be_within(1).of(15)
      end
      
      it 'should set the first visit message' do 
        expect(traffic_cop.outgoing_response).to eq('foo')
      end

    end
    
          
    context 'continued visit' do 
      
      before(:each) do 
        traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'test',
                                                       avatar_key: 'test',
                                                       start_time: 30.seconds.ago,
                                                       stop_time: 15.seconds.ago,
                                                       duration: 15)
        FactoryBot.create(:detection, visit_id: traffic_cop.visits.first.id)    

        traffic_cop.update(detection: {
          avatar_name: 'test',
          avatar_key: 'test',
          position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                          transform_values { |v| v.round(4) }
        })  
        
      end
      it 'should not add a visit' do 
        expect(traffic_cop.visits.size).to eq 1
      end
      
      it 'should update the duration' do 
        expect(traffic_cop.visits.first.reload.duration).to be_within(1).of(45)
      end
      
      it 'should not set a message' do 
        expect(traffic_cop.outgoing_response).to be_nil
      end
    end
    
    context 'new visit same avie' do 
      context 'last visit was recent' do 
      
        before(:each) do 
          traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'test',
                                                         avatar_key: 'test',
                                                         start_time: 6.minutes.ago,
                                                         stop_time: 4.minutes.ago,
                                                         duration: 120)
          FactoryBot.create(:detection, visit_id: traffic_cop.visits.first.id)    
  
          traffic_cop.update(detection: {
            avatar_name: 'test',
            avatar_key: 'test',
            position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                            transform_values { |v| v.round(4) }
          })  
          
        end
        it 'should not add a visit' do 
          expect(traffic_cop.visits.size).to eq 2
        end
        
        it 'should update the duration' do 
          expect(traffic_cop.visits.last.duration).to be_within(1).of(15)
        end
        
        it 'should not set a message' do 
          expect(traffic_cop.outgoing_response).to be_nil
        end
      end
      
      context 'last visit was not recent' do 
      
        before(:each) do 
          traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'test',
                                                         avatar_key: 'test',
                                                         start_time: 8.days.ago,
                                                         stop_time: 8.days.ago + 30.minutes,
                                                         duration: 30)
          FactoryBot.create(:detection, visit_id: traffic_cop.visits.first.id)    
  
          traffic_cop.update(detection: {
            avatar_name: 'test',
            avatar_key: 'test',
            position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                            transform_values { |v| v.round(4) }
          })  
          
        end
        it 'should not add a visit' do 
          expect(traffic_cop.visits.size).to eq 2
        end
        
        it 'should update the duration' do 
          expect(traffic_cop.visits.last.duration).to be_within(1).of(15)
        end
        
        
        it 'should set the correct message' do 
          expect(traffic_cop.outgoing_response).to eq 'bar'
        end
      end
    end
    
    context 'new visit new avie' do 
      
      before(:each) do 
        traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'test',
                                                       avatar_key: 'test',
                                                       start_time: 6.minutes.ago,
                                                       stop_time: 4.minutes.ago,
                                                       duration: 120)
        FactoryBot.create(:detection, visit_id: traffic_cop.visits.first.id)    

        traffic_cop.update(detection: {
          avatar_name: 'new',
          avatar_key: 'new',
          position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                          transform_values { |v| v.round(4) }
        })  
        
      end
      it 'should not add a visit' do 
        expect(traffic_cop.visits.size).to eq 2
      end
      
      it 'should update the duration' do 
        expect(traffic_cop.visits.last.reload.duration).to be_within(1).of(15)
      end
    end
    
    context 'access_mode_banned' do 
      it 'should set has_access to false if the avatar is banned' do 
        traffic_cop.access_mode = :access_mode_banned
        traffic_cop.save
        traffic_cop.listable_avatars << FactoryBot.build(:banned_avatar, avatar_name: 'test', 
                                                                         avatar_key: 'test')
        # traffic_cop.save
        traffic_cop.update(detection: {
                avatar_name: 'test',
                avatar_key: 'test',
                position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                                transform_values { |v| v.round(4) }
              })  
        expect(traffic_cop.has_access).to be_falsey
      end
      it 'should set has_access to true if the avatar is not banned' do 
        traffic_cop.access_mode = :access_mode_banned
        traffic_cop.save
        traffic_cop.listable_avatars << FactoryBot.build(:banned_avatar, avatar_name: 'test', 
                                                                         avatar_key: 'test')
        
        traffic_cop.update(detection: {
              avatar_name: 'not_test',
              avatar_key: 'not_Test',
              position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                              transform_values { |v| v.round(4) }
            })  
        expect(traffic_cop.has_access).to be_truthy
      end
    end 
    
    
    
    context 'access_mode_allowed' do 
      it 'should set has_access to false if the avatar is banned' do 
        traffic_cop.access_mode = :access_mode_allowed
        traffic_cop.save
        traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar, avatar_name: 'test', 
                                                                         avatar_key: 'test')
        # traffic_cop.save
        traffic_cop.update(detection: {
                avatar_name: 'test',
                avatar_key: 'test',
                position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                                transform_values { |v| v.round(4) }
              })  
        expect(traffic_cop.has_access).to be_truthy
      end
      it 'should set has_access to true if the avatar is not banned' do 
        traffic_cop.access_mode = :access_mode_allowed
        traffic_cop.save
        traffic_cop.listable_avatars << FactoryBot.build(:allowed_avatar, avatar_name: 'test', 
                                                                         avatar_key: 'test')
        
        traffic_cop.update(detection: {
              avatar_name: 'not_test',
              avatar_key: 'not_Test',
              position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }.
                              transform_values { |v| v.round(4) }
            })  
        expect(traffic_cop.has_access).to be_falsey
      end
    end
    
    
  end
  
end
