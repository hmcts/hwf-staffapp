require 'capybara/poltergeist'

Capybara.save_and_open_page_path = 'tmp'
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    timeout: 60,
    logger: nil,
    inspector: true,
    debug: false,
    js_errors: false,
    phantomjs_options: [
      '--load-images=no',
      '--ignore-ssl-errors=yes',
      '--ssl-protocol=tlsv1'
    ]
  )
end
