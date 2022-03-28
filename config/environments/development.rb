# frozen_string_literal: true

Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = true
    Bullet.alert         = true
    Bullet.bullet_logger = true
    Bullet.console       = true
    # Bullet.growl         = true
    Bullet.rails_logger  = true
    Bullet.add_footer    = true
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::Terminal',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::Server',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::DonationBox',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::TrafficCop',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::TipJar',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::Vendor',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::ParcelBox',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::TierStation',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::ShopRentalBox',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::ServiceBoard',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::TimeCop',
                        association: :abstract_web_object
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Analyzable::Inventory',
                        association: :user
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Analyzable::Employee',
                        association: :user
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::DonationBox',
                        association: :user
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Analyzable::Parcel',
                        association: :user
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::DonationBox',
                        association: :server
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Rezzable::DonationBox',
                        association: :transactions
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Analyzable::Transaction',
                        association: :web_object
    Bullet.add_safelist type: :n_plus_one_query,
                        class_name: 'AbstractWebObject',
                        association: :user
    Bullet.add_safelist type: :n_plus_one_query,
                        class_name: 'AbstractWebObject',
                        association: :server
    Bullet.add_safelist type: :n_plus_one_query,
                        class_name: 'AbstractWebObject',
                        association: :transactions
    Bullet.add_safelist type: :n_plus_one_query,
                        class_name: 'Analyzable::Inventory',
                        association: :user
    Bullet.add_safelist type: :counter_cache, class_name: 'User', association: :web_objects
    Bullet.add_safelist type: :n_plus_one_query,
                        class_name: 'AbstractWebObject',
                        association: :actable
    Bullet.add_safelist type: :n_plus_one_query,
                        class_name: 'Analyzable::Transaction',
                        association: :transactable
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # allows cloud nine
  config.hosts << "91c01eb68fee48328a63bc0d89bddcdc.vfs.cloud9.us-east-2.amazonaws.com"

  # Show full error reports.
  config.consider_all_requests_local = true

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.webpacker.check_yarn_integrity = false

  config.web_console.permissions = '152.7.255.0/16'
end
