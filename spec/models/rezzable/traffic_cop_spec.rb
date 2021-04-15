# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::TrafficCop, type: :model do
  it { should respond_to :abstract_web_object }

  it {
    should have_many(:visits).dependent(:nullify)
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
  let(:server) do
    server = FactoryBot.create :server, user_id: user.id
    server.inventories << FactoryBot.build(:inventory, inventory_name: 'foo')
    server.inventories << FactoryBot.build(:inventory, inventory_name: 'bar')
    server
  end
  let(:traffic_cop) {
    FactoryBot.create :traffic_cop, user_id: user.id,
                                    first_visit_message: 'foo',
                                    repeat_visit_message: 'bar',
                                    server_id: server.id
  }
  
  describe '#current_visitors' do 
    before(:each) do 
      traffic_cop.visits << FactoryBot.build(:visit, start_time: 2.hours.ago, 
                                                     stop_time: 1.hour.ago, 
                                                     duration: 1.hour)
                                                     
      traffic_cop.visits << FactoryBot.build(:visit, start_time: 1.hours.ago, 
                                                     stop_time: 15.seconds.ago, 
                                                     duration: 1.hour - 15.seconds)
                                                     
      traffic_cop.visits << FactoryBot.build(:visit, start_time: 1.hours.ago, 
                                                     stop_time: 30.seconds.ago, 
                                                     duration: 1.hour - 30.seconds)
      
    end
    
    it 'should return only the current visitors' do 
      expect(traffic_cop.current_visitors.size).to eq 2
    end
  end

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
                             position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                          .transform_values { |v| v.round(4) }
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
                             position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                          .transform_values { |v| v.round(4) }
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
                               position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                            .transform_values { |v| v.round(4) }
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
                               position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                            .transform_values { |v| v.round(4) }
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
                             position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                          .transform_values { |v| v.round(4) }
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
                             position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                                .transform_values { |v| v.round(4) }
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
                             position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                              .transform_values { |v| v.round(4) }
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
                             position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                                .transform_values { |v| v.round(4) }
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
                             position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                              .transform_values { |v| v.round(4) }
                           })
        expect(traffic_cop.has_access).to be_falsey
      end
    end

    context 'sending inventory' do
      let(:uri_regex) {
        %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/inventory/give/foo\?
                            auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
      }
      before(:each) do
        @stub = stub_request(:post, uri_regex)
      end
      context 'when inventory is not set' do
        it 'should not send anything' do
          traffic_cop.update(detection: {
                               avatar_name: 'Random Citizen',
                               avatar_key: 'foo',
                               position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                            .transform_values { |v| v.round(4) }
                             })
          expect(@stub).to_not have_been_requested
        end
      end

      context 'when inventory is set' do
        before(:each) do
          traffic_cop.inventory_to_give = 'foo'
          traffic_cop.save
        end
        context 'and the avatars first visit' do
          it 'should request the inventory be given' do
            traffic_cop.update(detection: {
                                 avatar_name: 'Random Citizen',
                                 avatar_key: 'foo',
                                 position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                              .transform_values { |v| v.round(4) }
                               })

            expect(@stub).to have_been_requested
          end
        end

        context 'and the avatars recent repeat visit' do
          it 'should not request the inventory give' do
            traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'Random Citizen',
                                                           avatar_key: 'foo',
                                                           start_time: 2.days.ago,
                                                           stop_time: 2.day.ago + 1.hour,
                                                           duration: 1.hour.to_i)

            traffic_cop.update(detection: {
                                 avatar_name: 'Random Citizen',
                                 avatar_key: 'foo',
                                 position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                              .transform_values { |v| v.round(4) }
                               })

            expect(@stub).to_not have_been_requested
          end
        end

        context 'and the avatars later repeat visit' do
          it 'should not request the inventory give' do
            traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'Random Citizen',
                                                           avatar_key: 'foo',
                                                           start_time: 10.days.ago,
                                                           stop_time: 10.day.ago + 1.hour,
                                                           duration: 1.hour.to_i)

            traffic_cop.update(detection: {
                                 avatar_name: 'Random Citizen',
                                 avatar_key: 'foo',
                                 position: { x: (rand * 256), y: (rand * 256), z: (rand * 4096) }
                              .transform_values { |v| v.round(4) }
                               })

            expect(@stub).to have_been_requested
          end
        end
      end
    end
  end
  
  describe '#visitors' do     before(:each) do 
    traffic_cop.visits << FactoryBot.build(:visit, start_time: 2.hours.ago, 
                                                   stop_time: 1.hour.ago, 
                                                   duration: 1.hour)
                                                   
    traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'foo',
                                                   avatar_key: 'bar',
                                                   start_time: 1.hours.ago, 
                                                   stop_time: 15.seconds.ago, 
                                                   duration: 1.hour - 15.seconds)
                                                   
    traffic_cop.visits << FactoryBot.build(:visit, avatar_name: 'foo',
                                                   avatar_key: 'bar',
                                                   start_time: 1.hours.ago, 
                                                   stop_time: 30.seconds.ago, 
                                                   duration: 1.hour - 30.seconds)
      
    end
    it 'should return the summed time spent by each avatar' do 
      expect(traffic_cop.visitors.size).to eq 2
    end
  end
end
