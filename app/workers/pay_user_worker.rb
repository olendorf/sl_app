# frozen_string_literal: true

# Queues giving inventory jobs
class PayUserWorker
  include Sidekiq::Worker

  def perform(server_id, avatar_name, avatar_key, amount)
    ServerSlRequest.pay_user(server_id, avatar_name, avatar_key, amount)
  end
end
