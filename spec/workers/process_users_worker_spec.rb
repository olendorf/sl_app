# frozen_string_literal: true

require 'rails_helper'
# require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe ProcessUsersWorker, type: :worker do
  before(:each) do
    owners = FactoryBot.create_list(:owner, 3)
    3.times do
      owners.sample.web_objects << FactoryBot.create(:server)
    end
  end
  describe 'queing the job' do
    it 'job in correct queue' do
      described_class.perform_async
      assert_equal 'default', described_class.queue
    end

    it 'goes into the jobs array for testing environment' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).by(1)
      described_class.new.perform
    end
  end
end
