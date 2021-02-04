# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# code coverage
gem 'coveralls', require: false

# Decorator pattern gem
gem 'draper'

# authentication
gem 'devise'
# authorization
gem 'pundit'

# Track changes to your models, for auditing or versioning
gem 'paper_trail'

# Admin interface with the data. Will probably use for a user interface as well
gem 'activeadmin'

# fun ways to generate data
gem 'faker'

# Simulates multi table inheritance
gem 'active_record-acts_as'

# Easy app configuration
gem 'config'

# Nice display of time differences
gem 'time_diff'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner'                  # Allows isolated testing of DB interactions.
  gem 'factory_bot_rails'
  gem 'guard-rspec'                       # Integrate Guard with Rspec
  gem 'guard-spring'                      # Integrate Guard with Spring
  gem 'rspec-rails'                       # Rspec
  gem 'shoulda-matchers'                  # Really handy RSpec matchers not included with RSpec
  gem 'spring-commands-rspec', group: :development
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'webmock'   # Allows mocking of web apis for instance
end
