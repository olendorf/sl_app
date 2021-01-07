# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UserPolicy, type: :policy do
  let(:owner) { FactoryBot.create :owner }
  let(:user) { FactoryBot.create :active_user }

  let(:web_object) { FactoryBot.build :web_object }
  let(:owner_object) {
    object = FactoryBot.build :web_object, user_id: owner.id
    object.save
    object
  }

  let(:user_object) {
    object = FactoryBot.build :web_object, user_id: user.id
    object.save
    object
  }

  subject { described_class }

  permissions :create? do
    it 'grants permission to any user' do
      expect(subject).to permit nil, nil
    end
  end

  permissions :show?, :update?, :destroy? do
    context 'owner object' do
      it 'grants permission' do
        expect(subject).to permit owner, owner_object
      end
    end

    context 'user object' do
      it 'does not grant permission' do
        expect(subject).to_not permit user, user_object
      end
    end
  end
end
