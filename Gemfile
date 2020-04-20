source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'application_insights', '~> 0.5.6'
gem 'dotenv-rails', groups: [:development, :test] # this has to be here because of load order

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
gem 'sentry-raven'
# Use postgresql as the database for Active Record
gem 'pg', '0.20'
gem 'rack-host-redirect'
gem 'rails-i18n', '~> 4.0.0'

# Azure key vault secrets to ENV variables
gem 'azure_env_secrets', github: 'ministryofjustice/azure_env_secrets', tag: 'v0.1.3'

# configuration
gem 'config'
# speed up start
gem 'bootsnap', require: false

# authentication
gem 'devise'
gem 'devise-security', '~> 0.14.3'
gem 'devise_invitable'

# authorisation
gem 'pundit', '~> 1.0'

# background jobs and scheduling
gem 'delayed_job_active_record'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# template language
gem 'slim-rails', '3.1.1'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'logstasher', git: 'https://github.com/shadabahmed/logstasher.git',
                  ref: '0b80e972753ba7ef36854b48d2c371e32963bc8d'
gem 'unicorn'
gem 'unicorn-worker-killer'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Date validation
gem 'date_validator'
gem 'will_paginate'

# Soft deletion
gem "paranoia", "~> 2.0"

# tracking model changes
gem "paper_trail"

# Google tag Manager
gem 'gtm_on_rails'

group :development do
  # speed up local development via livereload
  gem 'guard-livereload'
  gem 'rack-livereload'
  gem 'terminal-notifier-guard'
  gem 'web-console', '~> 3.7.0'
end

gem 'nokogiri'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-rails'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'rspec-rails', '~> 3.4'
  gem 'spring'
  # in browser debugging
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'climate_control'
  gem 'factory_bot_rails', '5.0.2'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'jasmine'
  gem 'rubocop', '~> 0.69.0', require: false
  gem 'rubocop-rspec', '1.30.1', require: false
  gem 'timecop'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'chromedriver-helper', '~> 1.1'
  gem 'codeclimate-test-reporter', '0.6.0', require: nil
  gem 'cucumber-rails', '~> 1.5', require: false
  gem 'database_cleaner'
  gem 'faker'
  gem 'geckodriver-helper', '~> 0.0'
  gem 'launchy'
  gem 'poltergeist', '1.15.0'
  gem 'pry'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'selenium-webdriver', '~> 3.10'
  gem 'shoulda-matchers'
  gem 'site_prism', '~> 2.9'
  gem 'webmock'
end

# heroku deployment
gem 'rails_12factor', group: :production

gem 'chartkick', '~> 3.3.0'
gem 'ckeditor', '~> 5.1'
gem 'groupdate'
gem 'pg_search'
gem 'rest-client'
gem 'virtus'
