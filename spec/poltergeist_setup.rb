require 'capybara/poltergeist'

Capybara.save_and_open_page_path = 'tmp'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5
