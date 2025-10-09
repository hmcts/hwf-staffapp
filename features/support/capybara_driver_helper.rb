require 'selenium/webdriver'

Selenium::WebDriver.logger.level = :error

Capybara.configure do |config|
  driver = ENV['DRIVER']&.to_sym || :cuprite
  config.default_driver = driver
  config.default_max_wait_time = 10
  config.default_normalize_ws = true
  config.match = :prefer_exact
  config.exact = true
  config.visible_text_only = true
end

# Temporary fix for "Unable to find latest point release version for 115.0.5790." error
# Webdrivers::Chromedriver.required_version = "114.0.5735.90"

Capybara.register_driver :headless do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new(args: ['headless', 'disable-gpu'])
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
end

Capybara.register_driver :firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.args << '--headless'
  options.args << '--disable-gpu'
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(app, { js_errors: false })
end

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, {
                                  js_errors: false,
                                  window_size: [1920, 1080],
                                  browser_options: {
                                    'no-sandbox': nil,
                                    'disable-gpu': nil,
                                    'disable-dev-shm-usage': nil
                                  }
                                })
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara::Screenshot.register_driver(:cuprite) do |driver, path|
  driver.save_screenshot(path, full: true)
end

Capybara.register_driver :saucelabs do |app|
  browser = Settings.saucelabs.browsers.send(Settings.saucelabs.browser).to_h
  Capybara::Selenium::Driver.new(app, browser: :remote, url: Settings.saucelabs.url, desired_capabilities: browser)
end

if ENV.key?('CIRCLE_ARTIFACTS')
  Capybara.save_and_open_page_path = ENV['CIRCLE_ARTIFACTS']
end

Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |scenario|
  title = scenario.name.
          gsub(/[^\w\s-]/, ''). # Remove all non-word, non-space, non-dash characters
          strip.
          tr(' ', '-').squeeze('-'). # Replace multiple consecutive dashes with single dash
          gsub(%r{/^.*/cucumber//}, '')
  "screenshot_cucumber_#{title}"
end

Capybara.always_include_port = true
Capybara.javascript_driver = Capybara.default_driver

# if ENV['LOCAL_SMOKE_TESTS']
#   ENV['TEST_URL'] = 'http://localhost:3000/'
# end

if ENV['TEST_URL'] && ENV['RUN_SMOKE_TESTS'] == 'true'
  Capybara.app_host = ENV['TEST_URL']
  Capybara.run_server = false
else
  Capybara.app_host = ENV.fetch('CAPYBARA_APP_HOST', "http://#{ENV.fetch('HOSTNAME', 'localhost')}")
  Capybara.server_host = ENV.fetch('CAPYBARA_SERVER_HOST', ENV.fetch('HOSTNAME', 'localhost'))
  Capybara.server_port = ENV.fetch('CAPYBARA_SERVER_PORT', '3000') unless
    ENV['CAPYBARA_SERVER_PORT'] == 'random'
end
