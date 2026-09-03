## Accessibility testing with Axe

The [Service Standard](https://www.gov.uk/service-manual/helping-people-to-use-your-service/testing-for-accessibility) requires all services to meet level AA of the [Web Content Accessibility Guidelines 2.2](https://www.gov.uk/service-manual/helping-people-to-use-your-service/understanding-wcag) (WCAG 2.2) as a minimum. As part of this, code must be regularly tested for accessiblity using both manual and automated testing.

For automated accessibility testing we use [Axe](https://www.deque.com/axe/) and the [Axe Core gem](https://github.com/dequelabs/axe-core-gems).

The automated accessibility tests can be run using the rake command:

`$ bundle exec rake test:accessibility`

The tests cover:

- [accessibility/accessibility_admin.feature](accessibility_admin.feature) testing the admin pages.
- [accessibility/accessibility_staff.feature](accessibility_staff.feature) testing the staff pages.
- [accessibility/accessibility_public.feature](accessibility_public.feature) testing the public pages.
- [accessibility/accessibility_error_states.feature](accessibility_error_states.feature) testing form error states.

The test configuration and step definitions can be viewed in [step_definitions/accessibility_steps.rb](../features/step_definitions/accessibility_steps.rb).