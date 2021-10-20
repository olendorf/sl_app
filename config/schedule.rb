# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, 'log/cron_log.log'
set :environment, 'development'

job_type :sidekiq, 'cd :path && :environment_variable=:environment bundle exec sidekiq-client push :task :output'

every 1.minute do
  sidekiq 'HelloWorldWorker'
end

every 2.minutes do
  sidekiq 'UserCleanupWorker'
end

every 3.minutes do
  sidekiq 'GoodbyeWorldWorker'
end
