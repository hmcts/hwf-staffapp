# Automated testing

## Rubocop testing

To assess Ruby code quality across the application we use [Rubocop](https://github.com/bbatsov/rubocop).

To run the tool, use:

`$ rubocop`

## Cucumber feature testing

For integration and UI testing, we use [Cucumber](https://cucumber.io/) and [Capybara](https://github.com/teamcapybara/capybara).

To run the standard Cucumber test suite, use:

`$ bundle exec cucumber features`

To run the all scenarios in a particular feature file:

`$ bundle exec cucumber features/landing_page.feature`

To run a particular scenario using line number:

`$ bundle exec cucumber features/landing_page.feature:10`

## Cross-browser and device testing with 🎭 Playwright

By default, only Rack and Headless Selenium Chrome are used for the feature tests.

For cross-browser and device feature testing we use [Playwright](https://github.com/microsoft/playwright) and the [capybara-playwright-driver gem](https://github.com/YusukeIwaki/capybara-playwright-driver).

To begin, install yarn:

`$ yarn install`

Next, install playwright:

`$ yarn playwright install --with-deps`

Then, install the branded browsers:

`$ yarn playwright install chrome`

`$ yarn playwright install msedge`

Then run the test suite using the rake command:

`$ bundle exec rake test:cross_browser_device`

This will run `@javascript` tagged feature tests on Desktop Chrome, Desktop Edge, Desktop Firefox, Desktop WebKit, Mobile Chrome, and Mobile WebKit.

Mobile device emulation is based on an iPhone 15, configuration can be viewed at [/config/playwright.yml](/config/playwright.yml).

To run one of the drivers individually, e.g. Desktop Firefox run:

`$ DRIVER=playwright_firefox CAPYBARA_JS_DRIVER=playwright_firefox bundle exec cucumber`

All of the playwright drivers can be viewed in [support/playwright_driver_helper.rb](support/playwright_driver_helper.rb).

## Broken link checking with Lychee

To identify broken links we use [Lychee](https://lychee.cli.rs/) and the Lychee [command-line utility](https://github.com/lycheeverse/lychee).

To begin, install Lychee. For this example we are using [Homebrew](https://brew.sh/) - see [other installation methods](https://github.com/lycheeverse/lychee#installation).

`$ brew install lychee`

Then run the checks using the rake command:

`$ bundle exec rake test:links`

This checks external links in `app/views/**/*`, `app/helpers/**/*.rb`, `config/locales/**/*.yml`, and `public/*.html`.

Internal, Intranet, and SharePoint links are excluded.

The scanned directories can be configured in [/lib/tasks/test.rake](../lib/tasks/test.rake). Lychee can be configured in [lychee.toml](../lychee.toml)

## Brakeman

[Brakeman](https://github.com/presidentbeef/brakeman) is a static analysis tool which checks Ruby on Rails applications for security vulnerabilities.
