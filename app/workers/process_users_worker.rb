# frozen_string_literal: true

# Queues up message_users for background processing
class ProcessUsersWorker
  include Sidekiq::Worker

  def perform(*_args)
    User.message_users
  end
end
