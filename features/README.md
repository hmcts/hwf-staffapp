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

## Accessibility testing with Axe

The [Service Standard](https://www.gov.uk/service-manual/helping-people-to-use-your-service/testing-for-accessibility) requires all services to meet level AA of the [Web Content Accessibility Guidelines 2.2](https://www.gov.uk/service-manual/helping-people-to-use-your-service/understanding-wcag) (WCAG 2.2) as a minimum. As part of this, code must be regularly tested for accessiblity using both manual and automated testing.

For automated accessibility testing we use [Axe](https://www.deque.com/axe/) and the [Axe Core gem](https://github.com/dequelabs/axe-core-gems).

The automated accessibility tests can be run using the rake command:

`$ bundle exec rake test:accessibility`

The tests cover:

- [features/accessibility_admin.feature](accessibility_admin.feature) testing the admin pages.
- [features/accessibility_staff.feature](accessibility_staff.feature) testing the staff pages.
- [features/accessibility_public.feature](accessibility_public.feature) testing the public pages.
- [features/accessibility_error_states.feature](accessibility_error_states.feature) testing form error states.

The test configuration and step definitions can be viewed in [step_definitions/accessibility_steps.rb](step_definitions/accessibility_steps.rb).

## Brakeman

[Brakeman](https://github.com/presidentbeef/brakeman) is a static analysis tool which checks Ruby on Rails applications for security vulnerabilities.
