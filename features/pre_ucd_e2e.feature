Feature: Pre-UCD end-to-end Tests

  Background: Setup
    Given UCD changes are inactive

  Scenario: Process paper application
    Given I successfully sign in as a user
    And I start to process a new paper application
    And I successfully submit my required personal details
    And I successfully submit my required application details pre UCD
    And I sucessfully submit my savings and investments pre UCD
    And I answer yes to the benefits question
    And I submit the application signed by myself
    And I should see check details page pre UCD
    When I successfully submit my application
    And I should see that the applicant is eligible for help with fees

  Scenario: Process online application
    And I have looked up an online application with benefits
    When I see the application details
    When I fill in missing online application details
    And I click next
    Then I should be taken to the check details page
    When I successfully submit my application
    And I should see that the applicant is eligible for help with fees