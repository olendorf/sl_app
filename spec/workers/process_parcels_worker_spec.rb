# frozen_string_literal: true

require 'rails_helper'

Sidekiq::Testing.fake!

RSpec.describe ProcessParcelsWorker, type: :worker do
  let(:user) { FactoryBot.create :active_user }

  before(:each) do
    3.times do
      user.parcels << FactoryBot.create(:parcel, user_id: user.id)
    end
  end

  describe 'queing the job' do
    it 'job in correct queue' do
      described_class.perform_async(user)
      assert_equal 'default', described_class.queue
    end

    it 'goes into the jobs array for testing environment' do
      expect do
        described_class.perform_async(user)
      end.to change(described_class.jobs, :size).by(1)
      described_class.new.perform(user)
    end
  end
end
