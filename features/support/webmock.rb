require 'webmock/cucumber'
require_relative './capybara_driver_helper'

WebMock.allow_net_connect!(net_http_connect_on_start: true, allow_localhost: true)
