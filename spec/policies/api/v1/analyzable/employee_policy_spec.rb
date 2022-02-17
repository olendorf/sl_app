require 'rails_helper'

RSpec.describe Api::V1::Analyzable::EmployeePolicy, type: :policy do
  subject { described_class }

  let(:employee) { FactoryBot.build :employee }

  permissions :create?, :update?, :destroy?, :show?, :index?, :pay?, :pay_all? do
    it 'should grant permission to active users' do
      user = FactoryBot.create :active_user
      expect(subject).to permit user, employee
    end

    it 'should grant permission to owners' do
      user = FactoryBot.create :owner
      expect(subject).to permit user, employee
    end

    it 'should not grant permission to inactive users' do
      user = FactoryBot.create :inactive_user
      expect(subject).to_not permit user, employee
    end
  end
end
