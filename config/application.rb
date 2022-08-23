# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Default application file
module SlApp
  # Default for rails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.active_record.belongs_to_required_by_default = false

    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    config.time_zone = 'America/Los_Angeles'
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess]
    config.active_job.queue_adapter = :sidekiq
  end
end
