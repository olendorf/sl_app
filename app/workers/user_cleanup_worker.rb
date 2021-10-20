class UserCleanupWorker
  include Sidekiq::Worker

  def perform(*args)
    User.cleanup_users
  end
end
