source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.0'

gem 'application_insights', '~> 0.5.6'
gem 'csv'
gem 'dotenv-rails', groups: [:development, :test] # this has to be here because of load order

gem 'rails', '~> 8.1', '>= 8.1.2'
gem 'redis'

# profiling in Sentry
gem 'stackprof'
gem 'sentry-rails', '~> 6.2'
# Use postgresql as the database for Active Record
gem 'i18n', '>= 1.10'
gem 'parser', '>= 3.1.2.0'
gem 'pg', '~> 1.2'
gem 'rack', '~> 3.2', '>= 3.2.3'

gem 'rails-i18n'

# Azure key vault secrets to ENV variables
gem 'azure_env_secrets', github: 'hmcts/azure_env_secrets', tag: 'v1.0.1'
gem 'azure-blob', '~> 0.7.0'
gem 'hwf_hmrc_api', github: 'hmcts/hwf_hmrc_api', tag: 'v0.3.2'

# configuration
gem 'config'
# speed up start
gem 'bootsnap', require: false

# authentication
gem 'devise', '>= 4.9.3'
gem 'devise_invitable', '>= 2.0.9'
gem 'devise-security', '~> 0.18.0'

# authorisation
gem 'pundit', '~> 2.1'
gem 'ostruct'

# background jobs and scheduling
gem 'delayed_cron_job'
gem 'delayed_job_active_record'
gem 'benchmark'

gem 'propshaft'
gem 'cssbundling-rails'
gem 'jsbundling-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '>= 2', group: :doc

gem 'logstasher', '~> 3.0'
gem 'slim-rails'

gem 'puma', '~> 7.0', '>= 7.0.1'

gem 'will_paginate'

# Soft deletion
gem "paranoia"

# tracking model changes
gem "paper_trail"

# encrypting stored data
gem 'simple_encryptable'

# Google tag Manager
gem 'gtm_on_rails'

gem 'chartkick'
gem 'groupdate'
gem 'nokogiri'
gem 'pg_search'
gem 'faraday', '~> 2.14'
gem 'rubyzip', require: 'zip'
gem 'virtus'

# To pass vulnerability in 3.3.5
gem 'rexml', '>= 3.3.9'
gem 'uri', '>= 1.0.3'
gem 'cgi', '~> 0.5.1'
# GovUK Notify
gem 'govuk_notify_rails'

group :development, :test do
  gem 'mutex_m'
  gem 'bullet'
  gem 'bundler-audit'
  gem 'debug'
  gem 'byebug'
  gem 'climate_control'
  gem 'factory_bot_rails'
  gem 'listen'
  gem 'parallel_tests'
  gem 'pry-rails'
  gem 'readline'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rspec_rails'
  gem 'simplecov', '~> 0.22.0'
end

group :test do
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
  gem 'cuprite'
  gem 'brakeman'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'cucumber', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner-active_record'
  gem 'faker'
  gem 'launchy'
  gem 'mock_redis'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers'
  gem 'site_prism'
  gem "test-prof", "~> 1.0"
  gem 'webmock'
  gem 'selenium-webdriver', '~> 4.14'
end

gem "image_processing", "~> 1.14"
