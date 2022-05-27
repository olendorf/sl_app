# frozen_string_literal: true

# Queues up jobs to message users about their account status.
class MessageUserWorker
  include Sidekiq::Worker

  def perform(server_id, avatar_name, message)
    ServerSlRequest.message_user(server_id, avatar_name,
                                 message)
  end
end
