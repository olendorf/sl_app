# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Analyzable::ParcelPolicy, type: :policy do
  subject { described_class }

  let(:parcel) { FactoryBot.build :parcel }

  permissions :create?, :update?, :destroy?, :show?, :index? do
    it 'should grant permission to active users' do
      user = FactoryBot.create :active_user
      expect(subject).to permit user, parcel
    end

    it 'should grant permission to owners' do
      user = FactoryBot.create :owner
      expect(subject).to permit user, parcel
    end

    it 'should not grant permission to inactive users' do
      user = FactoryBot.create :inactive_user
      expect(subject).to_not permit user, parcel
    end
  end
end
