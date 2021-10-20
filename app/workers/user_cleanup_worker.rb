# frozen_string_literal: true

# Removes objects and data from users who are behind and
# on their account.
class UserCleanupWorker
  include Sidekiq::Worker

  def perform(*_args)
    User.cleanup_users
  end
end
