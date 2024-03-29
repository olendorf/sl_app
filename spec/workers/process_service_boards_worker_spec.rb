# frozen_string_literal: true

require 'rails_helper'

Sidekiq::Testing.fake!

RSpec.describe ProcessServiceBoardsWorker, type: :worker do
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
