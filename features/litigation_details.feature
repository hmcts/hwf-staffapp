Feature: Litigation details page

  Background: Litigation details page
    Given I am on the litigation details page

    Scenario: Successfully submit litigation details
      When I successfully submit litigation details
      Then I should be taken to the application details page

    Scenario: Enter applicants litigation details error message
      When I click next without adding the applicants litigation details
      Then I should see enter applicants litigation details error message
