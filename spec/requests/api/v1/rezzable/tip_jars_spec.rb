# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::TipJars', type: :request do
  it_behaves_like 'a user object API', :tip_jar

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:tip_jar) { FactoryBot.create :tip_jar, user_id: user.id, server_id: server.id }
  let(:path) { api_rezzable_tip_jar_path(tip_jar) }
  let(:avatar) { FactoryBot.build :avatar }
  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  describe 'tip jar sessions' do
    context 'user logs in' do
      let(:atts) {
        {
          session: {
            avatar_name: avatar.avatar_name,
            avatar_key: avatar.avatar_key
          }
        }
      }
      context 'access mode all' do
        it 'should return ok status' do
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(response.status).to eq 200
        end

        it 'should add the current session' do
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.sessions.size).to eq 1
        end

        it 'should be the correct session' do
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.current_session.avatar_key).to eq avatar.avatar_key
        end
      end

      # Has to be handles in world, so the same
      context 'access mode group' do
        before(:each) { tip_jar.update(access_mode: :access_mode_group) }
        it 'should return ok status' do
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(response.status).to eq 200
        end

        it 'should add the current session' do
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.sessions.size).to eq 1
        end

        it 'should be the correct session' do
          put path, params: atts.to_json, headers: headers(tip_jar)
          expect(tip_jar.current_session.avatar_key).to eq avatar.avatar_key
        end
      end

      context 'access mode list' do
        before(:each) do
          tip_jar.update(access_mode: :access_mode_list)
        end
        context 'user is not on list' do
          it 'should return forbidden status' do
            put path, params: atts.to_json, headers: headers(tip_jar)
            expect(response.status).to eq 403
          end
        end
      end
    end

    describe 'user logs out' do
      let(:atts) {
        {
          session: {
            avatar_name: nil,
            avatar_key: nil
          }
        }
      }

      before(:each) do
        tip_jar.sessions << FactoryBot.build(:session, avatar_name: avatar.avatar_name,
                                                       avatar_key: avatar.avatar_key)
      end

      it 'should return ok status' do
        put path, params: atts.to_json, headers: headers(tip_jar)
        expect(response.status).to eq 200
      end

      it 'should close the session' do
        put path, params: atts.to_json, headers: headers(tip_jar)
        expect(tip_jar.current_session).to be_nil
      end
    end

    describe 'handling tips' do
      before(:each) do
        tip_jar.sessions << FactoryBot.build(:session, avatar_name: avatar.avatar_name,
                                                       avatar_key: avatar.avatar_key)
        @stub = stub_request(:post, uri_regex)
      end
      let(:tipper) { FactoryBot.build :avatar }
      let(:atts) {
        { tip: { target_name: tipper.avatar_name, target_key: tipper.avatar_key, amount: 100 } }
      }
      it 'should return ok status' do
        put path, params: atts.to_json, headers: headers(tip_jar)
        expect(response.status).to eq 200
      end

      it 'should add transactions to the user' do
        put path, params: atts.to_json, headers: headers(tip_jar)
        expect(user.reload.transactions.size).to eq 2
      end

      it 'should request money be given to the tippee' do
        put path, params: atts.to_json, headers: headers(tip_jar)
        expect(@stub).to have_been_requested
      end
    end
  end
end
