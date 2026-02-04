Feature: Pre-UCD end-to-end Tests

  Background: Setup
    Given UCD changes are inactive

  Scenario: Process paper application with benefits - full remission (pre-UCD)
    Given I successfully sign in as a user
    And I start to process a new paper application
    Then I am on the personal details page
    When I successfully submit my required personal details
    And I successfully submit my required application details pre UCD
    And I sucessfully submit my savings and investments pre UCD
    And I answer yes to the benefits question
    Then I should be one the declaration page
    When I submit the application signed by myself
    Then I should see check details page pre UCD
    When I successfully submit my application
    Then I should see that the applicant is eligible for help with fees

  Scenario: Process paper application without benefits - income based (pre-UCD)
    Given I successfully sign in as a user
    And I start to process a new paper application
    Then I am on the personal details page
    When I successfully submit my required personal details
    And I successfully submit my required application details pre UCD
    And I sucessfully submit my savings and investments pre UCD
    And I answer no to the benefits question
    Then I should be taken to the incomes page
    When I answer yes to does the applicant financially support any children
    And I submit the total number of children
    And I submit 1200 total monthly income
    Then I should see check details page pre UCD
    When I successfully submit my application
    Then I should see that the applicant is eligible for help with fees

  Scenario: Process paper application refund (pre-UCD)
    Given I successfully sign in as a user
    And I start to process a new paper application
    Then I am on the personal details page
    When I successfully submit my required personal details
    When I submit a refund application where refund date is within 3 months of application received date pre UCD
    Then I should be taken to savings and investments page
    And I sucessfully submit my savings and investments pre UCD
    And I answer yes to the benefits question
    Then I should be one the declaration page
    When I submit the application signed by myself
    Then I should see check details page pre UCD
    When I successfully submit my application
    Then I should see that the applicant is eligible for help with fees

  Scenario: Process online application with benefits (pre-UCD)
    Given I have looked up an online application with benefits
    When I see the application details
    When I fill in missing online application details
    And I click next
    Then I should be taken to the check details page
    When I successfully submit my application
    And I should see that the applicant is eligible for help with fees
