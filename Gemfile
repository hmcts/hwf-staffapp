source 'https://rubygems.org'

gem 'dotenv-rails', groups: [:development, :test] # this has to be here because of load order

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7'
gem 'sentry-raven'
# Use postgresql as the database for Active Record
gem 'pg'
gem 'rails-i18n', '~> 4.0.0'
gem 'rack-host-redirect'

# configuration
gem 'config'

# authentication
gem 'devise'
gem 'devise_invitable'
# authorisation
gem 'pundit', '~> 1.0'

# background jobs and scheduling
gem 'delayed_job_active_record'

# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# use GDS assets, styles etc...
gem 'govuk_frontend_toolkit', '4.7.0'
gem 'govuk_elements_rails', '0.3.0'
gem 'moj_template', '~> 0.23.2'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# template language
gem 'slim-rails'
gem 'redcarpet'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn'
gem 'unicorn-worker-killer'
gem 'logstasher', git: 'https://github.com/shadabahmed/logstasher.git',
                  ref: '0b80e972753ba7ef36854b48d2c371e32963bc8d'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Date validation
gem 'date_validator'
gem 'will_paginate'

# Soft deletion
gem "paranoia", "~> 2.0"

gem 'whenever', require: false

group :development do
  # speed up local development via livereload
  gem 'guard-livereload'
  gem 'terminal-notifier-guard'
  gem 'rack-livereload'
  gem 'web-console', '~> 2.1'
end

gem 'nokogiri', '~> 1.6.8'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-rails'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails', '~> 3.4'
  # in browser debugging
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'factory_girl_rails'

  gem 'rubocop', '~>0.37.2', require: false
  gem 'rubocop-rspec', '~>1.4.0', require: false
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'jasmine'

  gem 'timecop'
  gem 'climate_control'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'webmock'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'capybara-webkit'
  gem 'faker'
  gem 'shoulda-matchers'
end

# heroku deployment
gem 'rails_12factor', group: :production

gem 'rest-client'
gem 'chartkick'
gem 'groupdate'
gem 'virtus'
