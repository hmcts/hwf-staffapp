Feature: Your last applications

  Background: Start and abandon a paper application
    Given UCD changes are active
    Given I successfully sign in as a user
    And I start to process a new paper application
    And I fill in the fee status of the application
    And I fill in personal details of the application
    And I fill in the application details
    And I abandon the application

    Scenario: Opening my last application
      When I open my last application
      Then I should see the personal details populated with information
      And I should see the application details populated with information
