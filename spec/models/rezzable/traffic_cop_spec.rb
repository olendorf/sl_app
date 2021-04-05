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

  let(:user) { FactoryBot.create :active_user }
  let(:traffic_cop) { FactoryBot.create :traffic_cop, user_id: user.id }

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
end
