# frozen_string_literal: true

# Removes objects and data from users who are behind and
# on their account.
class ProcessUsersWorker
  include Sidekiq::Worker

  def perform(*_args)
    User.process_users
  end
end
