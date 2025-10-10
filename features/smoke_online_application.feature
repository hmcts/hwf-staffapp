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

    When I start processing evidence page
    Then I should see applications details
    When I confirm evidence is ready
    And I fill in real income
    Then I should see that application is eligible for part payemnt
    And I confirm and complete the application
    Then I should see the confirmation page with results

    When I start processing part payment
    Then I should see part payment applications details
    When I confirm part payment is made
    And I will see that the applications was processed successfully