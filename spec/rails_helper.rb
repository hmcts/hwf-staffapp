require 'simplecov'
require "simplecov_json_formatter"

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ENV['DWP_API_PROXY'] ||= 'http://localhost:9292'

SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.start if ENV.fetch('ENABLE_COVERAGE', 'false').downcase == 'true'
# allow Code Climate Test coverage reports to be sent




if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
  # allow Code Climate Test coverage reports to be sent
end


require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'webmock/rspec'
require 'capybara/apparition'
require 'mock_redis'


# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.order = 'random'
  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
    mocks.allow_message_expectations_on_nil = true
  end

  # Include Factory Girl syntax to simplify calls to factories
  config.include FactoryBot::Syntax::Methods


  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include ApplicationFormMacros, type: :feature

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:all) do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.gstatic.com/charts/loader.js', 'chromedriver.storage.googleapis.com'])
  end

  config.before(:each) do |example|
    stub_request(:any, 'https://dc.services.visualstudio.com/v2/track')
  end

  Capybara.configure do |config|
    config.ignore_hidden_elements = false
  end

  Capybara.javascript_driver = :apparition
  Capybara.raise_server_errors = false

  config.before(:each) do
    ActionMailer::Base.deliveries = []
    DatabaseCleaner.strategy = :transaction
    FactoryBot.reload
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    mock_redis = MockRedis.new
    allow(Redis).to receive(:new).and_return(mock_redis)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
