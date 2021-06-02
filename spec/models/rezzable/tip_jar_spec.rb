# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::TipJar, type: :model do
  
  it_behaves_like 'a rezzable object', :tip_jar, 1
  
  it { should respond_to :abstract_web_object }

  # it_behaves_like 'it transactable', :tip_jar

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
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:tip_jar) {
    FactoryBot.create :tip_jar, user_id: user.id, split_percent: 90, server_id: server.id
  }

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

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

  describe 'handling tips' do
    let(:tipper) { FactoryBot.build :avatar }
    let(:tip) {
      {
        tip: {
          avatar_name: tipper.avatar_name,
          avatar_key: tipper.avatar_key,
          amount: 100
        }
      }
    }
    context 'no current session' do
      it 'should raise an bad request exception' do
        atts = FactoryBot.attributes_for(:tip,
                                         target_name: tipper.avatar_name,
                                         target_key: tipper.avatar_key,
                                         amount: 100)
        expect {
          tip_jar.update(tip: atts)
        }.to raise_error(ActionController::BadRequest)
      end
    end

    context 'current session' do
      before(:each) do
        tip_jar.sessions << FactoryBot.build(:session)

        @stub = stub_request(:post, uri_regex)
      end
      it 'should add the tip to the tip jar' do
        atts = FactoryBot.attributes_for(:tip,
                                         target_name: tipper.avatar_name,
                                         target_key: tipper.avatar_key,
                                         amount: 100)
        expect {
          tip_jar.update(tip: atts)
        }.to change { tip_jar.reload.transactions.size }.by(2)
      end

      it 'should give the shared split to the logged in user' do
        atts = FactoryBot.attributes_for(:tip,
                                         target_name: tipper.avatar_name,
                                         target_key: tipper.avatar_key,
                                         amount: 100)

        tip_jar.update(tip: atts)

        expect(@stub).to have_been_requested
      end

      it 'should update the user balance correctly' do
        atts = FactoryBot.attributes_for(:tip,
                                         target_name: tipper.avatar_name,
                                         target_key: tipper.avatar_key,
                                         amount: 100)

        tip_jar.update(tip: atts)
        expect(user.balance).to eq 10
      end

      it 'should update the session avatar if they have an account' do
        user_tipper = FactoryBot.create(:active_user,
                                        avatar_name: tip_jar.current_session.avatar_name,
                                        avatar_key: tip_jar.current_session.avatar_key)
        atts = FactoryBot.attributes_for(:tip,
                                         target_name: tipper.avatar_name,
                                         target_key: tipper.avatar_key,
                                         amount: 100)

        tip_jar.update(tip: atts)
        expect(user_tipper.reload.balance).to eq 90
      end
    end
  end
end
