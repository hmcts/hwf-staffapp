@javascript @accessibility
Feature: Accessibility of error states on forms

  Scenario: Date received and fee status page with errors
    Given I started to process paper application
    And I am on the fee status page
    When I click on next without answering any questions
    Then I should see that I must fill in date received
    And I should have to enter refund information
    And the "Date received and fee status - with errors" page should meet accessibility standards

  Scenario: Personal details page with errors
    Given I have started an application
    And I am on the personal details part of the application
    When I click on next without answering any questions
    Then I should see that I must fill in my last name
    And I should have to enter my date of birth
    And the "Personal details - with errors" page should meet accessibility standards

  Scenario: Savings and investments page with errors
    Given I have started an application
    And I am on the savings and investments part of the application
    When I click next without selecting a savings and investments option
    Then I should see a 'Please answer the savings question' error
    And the "Savings and investments - with errors" page should meet accessibility standards

  Scenario: Online application details page with errors
    Given I have looked up an online application with benefits
    When I see the application details
    And I click next without selecting a jurisdiction
    Then I should see that I must select a jurisdiction error message
    And the "Online application details - with errors" page should meet accessibility standards

  Scenario: Evidence page with errors
    Given there is an application waiting for evidence
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    When I click on next without making a selection on the evidence page
    Then I should see this question must be answered error message
    And the "Is the evidence ready to process - with errors" page should meet accessibility standards

  Scenario: Feedback page with errors
    Given I successfully sign in as a user
    And I am on your feedback page
    When I click on Send feedback
    Then I should see an error summary message
    And I should see a rating error
    And the "Your feedback - with errors" page should meet accessibility standards

  Scenario: Generate report page with errors
    Given I successfully sign in as admin
    And I am on the finance aggregated report page
    When I try and generate a report without entering dates
    Then I should see enter dates error message
    And the "Finance aggregated report - with errors" page should meet accessibility standards

