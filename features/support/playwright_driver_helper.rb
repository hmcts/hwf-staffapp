require 'yaml'
require 'capybara-playwright-driver'

playwright_config = YAML.load_file(Rails.root.join('config/playwright.yml'), symbolize_names: true)
playwright_options = playwright_config[:base]
playwright_mobile_options = playwright_options.merge(playwright_config[:mobile])

Capybara.register_driver(:playwright_chrome) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium, channel: 'chrome', **playwright_options)
end

Capybara.register_driver(:playwright_msedge) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium, channel: 'msedge', **playwright_options)
end

Capybara.register_driver(:playwright_firefox) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :firefox, **playwright_options)
end

Capybara.register_driver(:playwright_webkit) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :webkit, **playwright_options)
end

Capybara.register_driver(:playwright_mobile_chrome) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium, channel: 'chrome', **playwright_mobile_options)
end

Capybara.register_driver(:playwright_mobile_webkit) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :webkit, **playwright_mobile_options)
end
