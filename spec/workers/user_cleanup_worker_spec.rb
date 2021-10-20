require 'rails_helper'
# require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe UserCleanupWorker, type: :worker do
  describe 'queing the job' do 
    it "job in correct queue" do 
      described_class.perform_async
      assert_equal "default", described_class.queue
    end
  end
end
