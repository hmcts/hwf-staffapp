require 'selenium/webdriver'

Selenium::WebDriver.logger.level = :error

Capybara.configure do |config|
  driver = ENV['DRIVER']&.to_sym || :firefox
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

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  # Full page screenshot for Chrome
  original_size = driver.browser.manage.window.size
  total_width = driver.browser.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
  total_height = driver.browser.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
  
  driver.browser.manage.window.resize_to([total_width, 1200].max, [total_height, 1000].max)
  driver.browser.save_screenshot(path)
  driver.browser.manage.window.resize_to(original_size.width, original_size.height)
end

Capybara::Screenshot.register_driver(:firefox) do |driver, path|
  # Full page screenshot for Firefox
  original_size = driver.browser.manage.window.size
  total_width = driver.browser.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
  total_height = driver.browser.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
  
  driver.browser.manage.window.resize_to([total_width, 1200].max, [total_height, 1000].max)
  driver.browser.save_screenshot(path)
  driver.browser.manage.window.resize_to(original_size.width, original_size.height)
end

Capybara::Screenshot.register_driver(:apparition) do |driver, path|
  # Apparition supports full page screenshots natively
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
  title = scenario.name.tr(' ', '-').gsub(%r{/^.*/cucumber//}, '')
  "screenshot_cucumber_#{title}"
end

Capybara.always_include_port = true
Capybara.javascript_driver = Capybara.default_driver
Capybara.app_host = ENV.fetch('CAPYBARA_APP_HOST', "http://#{ENV.fetch('HOSTNAME', 'localhost')}")
Capybara.server_host = ENV.fetch('CAPYBARA_SERVER_HOST', ENV.fetch('HOSTNAME', 'localhost'))
Capybara.server_port = ENV.fetch('CAPYBARA_SERVER_PORT', '3000') unless
  ENV['CAPYBARA_SERVER_PORT'] == 'random'
