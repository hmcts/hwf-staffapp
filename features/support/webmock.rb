require 'webmock'
# rubocop:disable Style/MixinUsage
include WebMock::API
# rubocop:enable Style/MixinUsage
require_relative 'capybara_driver_helper'

selenium_url = URI.parse ENV.fetch('SELENIUM_URL', 'http://localhost:4444/wd/hub')
app_host_url = URI.parse Capybara.app_host

WebMock.disable_net_connect!(allow_localhost: true, net_http_connect_on_start: true, allow: [selenium_url.host, app_host_url.host, 'ondemand.saucelabs.com', 'chromedriver.storage.googleapis.com', 'https://messages.cucumber.io/api/reports'])
