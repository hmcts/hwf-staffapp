Feature: Override

  Background: Signed in as user
    Given I successfully sign in as a user
    And I have completed an ineligible paper application
    When I click on Grant help with fees

  Scenario: No reason given to override
    Given Click Update application without selecting an option
    Then I should see an error telling me to select an option
    And The application should remain ineligible
    And I should not see a message telling me the application passed by manager's decision

  Scenario: No details included with Other reason to override
    Given I check the Other option
    And Click Update application without providing detail
    Then I should see an error telling me to enter a reason for granting help with fees
    And The application should remain ineligible
    And I should not see a message telling me the application passed by manager's decision

  Scenario: Paper evidence gives reason to override
    Given I check the Paper evidence option
    And Click Update application
    Then I should see a message telling me the application passed by manager's decision
    And The application should become eligible

  Scenario: Details are included with Other reason to override
    Given I check the Other option
    And Click Update application after providing detail
    Then I should see a message telling me the application passed by manager's decision
    And The application should become eligible