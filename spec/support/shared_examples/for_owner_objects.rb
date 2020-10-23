# frozen_string_literal: true

RSpec.shared_examples 'it has an owner object policy' do |model_name|
  let(:owner) { FactoryBot.build :owner }
  let(:user) { FactoryBot.build :user, account_level: 1, expiration_date: 1.month.from_now }
  let(:web_object) { FactoryBot.build model_name.to_sym }

  subject { described_class }

  permissions :show?, :create?, :update?, :destroy? do
    it 'should return true for an owner' do
      expect(subject).to permit(owner, web_object)
    end

    it 'should not return true for a user' do
      expect(subject).to_not permit(user, web_object)
    end
  end
end
