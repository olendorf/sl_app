require 'rails_helper'

RSpec.describe Api::V1::Rezzable::WebObjectPolicy, type: :policy do
  let(:user) {  FactoryBot.create :active_user }
  let(:web_object) { FactoryBot.create :web_object, user_id: user.id }

  subject { described_class }

  permissions :show?, :create?, :update?, :index?, :destroy? do
    it 'grants permission to the user' do
      expect(subject).to permit(user, web_object)
    end
  end


end
