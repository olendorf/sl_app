# frozen_string_literal: true

# Queues up jobs to message users about their account status.
class MessageUserWorker
  include Sidekiq::Worker

  def perform(avatar_name, avatar_key, expiration_date)
    ServerSlRequest.account_payment_message(avatar_name, avatar_key, expiration_date)
  end
end
