# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AsyncPolicy, type: :policy do
  let(:active_user) { FactoryBot.build :active_user }

  subject { described_class }

  permissions :index? do
    it 'should allow an active user' do
      expect(subject).to permit active_user, :async
    end
  end
end
