Capybara.configure do |config|
  driver = ENV['DRIVER']&.to_sym || :headless
  config.default_driver = driver
  config.default_max_wait_time = 30
  config.match = :prefer_exact
  config.exact = true
  config.visible_text_only = true
end

Capybara.register_driver :headless do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: ['headless', 'disable-gpu']))
end

Capybara.javascript_driver = :chrome

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.register_driver :firefox do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
end

Capybara.register_driver :saucelabs do |app|
  browser = Settings.saucelabs.browsers.send(Settings.saucelabs.browser).to_h
  Capybara::Selenium::Driver.new(app, browser: :remote, url: Settings.saucelabs.url, desired_capabilities: browser)
end

if ENV.key?('CIRCLE_ARTIFACTS')
  Capybara.save_and_open_page_path = ENV['CIRCLE_ARTIFACTS']
end

Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |scenario|
  title = scenario.name.tr(' ', '-').gsub(%r{/^.*\/cucumber\//}, '')
  "screenshot_cucumber_#{title}"
end

Capybara.always_include_port = true
Capybara.app_host = ENV.fetch('CAPYBARA_APP_HOST', "http://#{ENV.fetch('HOSTNAME', 'localhost')}")
Capybara.server_host = ENV.fetch('CAPYBARA_SERVER_HOST', ENV.fetch('HOSTNAME', 'localhost'))
Capybara.server_port = ENV.fetch('CAPYBARA_SERVER_PORT', '3000') unless
  ENV['CAPYBARA_SERVER_PORT'] == 'random'
