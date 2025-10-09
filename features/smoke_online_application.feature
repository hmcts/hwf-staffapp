@smoke
Feature: Processed online applications

  Background: Processed applications page
    Given I am signed in as a smoke user

  Scenario: Process paper application application
    Given I am on the home page
    And start processing paper application
    Then I fill in fee status page details
    And I fill in personal details page details
    And I fill in application details page
    And the applicants has less savings then minimum threshold
    And the applicant is not on benefits
    And has no children
    And has income just from wages
    And the amount of income is 50 for last month
    And the applicant is filling the application just for themselves
    Then I should see check details page
    When I complete the application
    And the application is marked to be evidence_checked









