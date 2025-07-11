# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require_relative './page_objects/base_page'
require 'capybara/apparition'
require 'cucumber/rspec/doubles'
require 'database_cleaner/active_record'
require 'capybara/cucumber'
require 'capybara-screenshot/cucumber'
require 'base64'
require 'webmock'
require 'selenium/webdriver'
include WebMock::API
require 'mock_redis'

Dir[File.dirname(__FILE__) + '/page_objects/**/*.rb'].each { |f| require f }

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false
Capybara::Screenshot.autosave_on_failure = false
Capybara::Screenshot.prune_strategy = :keep_last_run

After do |scenario|
  if scenario.failed?
    # add_screenshot
    # add_browser_logs
  end
end

def add_screenshot
  file_path = 'features/cucumber-report/screenshot.png'
  page.driver.browser.save_screenshot(file_path)
  image = open(file_path, 'rb', &:read)
  encoded_image = Base64.encode64(image)
  attach(encoded_image, 'image/png;base64')
end

def add_browser_logs
  current_time = DateTime.now
  # Getting current URL
  current_url = Capybara.current_url.to_s
  # Gather browser logs
  logs = page.driver.browser.manage.logs.get(:browser).map {|line| [line.level, line.message]}
  # Remove warnings and info messages
  logs.reject! { |line| ['WARNING', 'INFO'].include?(line.first) }
  logs.any? == true
  attach(current_time.strftime("%d/%m/%Y %H:%M" + "\n") + ( "Current URL: " + current_url + "\n") + logs.join("\n"), 'text/plain')
end


#Define global variables
ENV['zap_proxy'] = "localhost"
ENV['zap_proxy_port'] = '8099'
ENV['HOSTNAME'] = 'localhost'

#Below lines are our driver profile settings to reach internet through a proxy
#You can set security=true as environment variable or declare it on command window
if ENV['security'] == "true"
  Capybara.register_driver :selenium do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile["network.proxy.type"] = 1
    profile["network.proxy.http"] = ENV['zap_proxy']
    profile["network.proxy.http_port"] = ENV['zap_proxy_port']
    Capybara::Selenium::Driver.new(app, :profile => profile)
  end
end

ENV['NO_PROXY'] = ENV['no_proxy'] = '127.0.0.1'
if ENV['APP_HOST']
  Capybara.app_host = ENV['APP_HOST']
  if Capybara.app_host.chars.last != '/'
    Capybara.app_host += '/'
  end
end

Capybara.raise_server_errors = false

Before do
  stub_request(:any, 'https://dc.services.visualstudio.com/v2/track')
  mock_redis = MockRedis.new
  allow(Redis).to receive(:new).and_return(mock_redis)

  app_insight = instance_double(ApplicationInsights::TelemetryClient, flush: '')
  allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
  allow(app_insight).to receive(:track_event)
end

Before do
  DatabaseCleaner.clean
end

Before do
  extend GuideHelper
end
