Feature: Override

  Background: Signed in as user
    Given UCD changes are active
    Given I successfully sign in as a user

  Scenario: No reason given to override high income application
    Given I have completed an ineligible paper application - income too high
    When I click on Grant help with fees
    Then I click Update application without selecting an option
    Then I should see an error telling me to select an option
    And The application should remain ineligible
    And I should not see a message telling me the application passed by manager's decision

  Scenario: No details included with Other reason to override
    Given I have completed an ineligible paper application - income too high
    When I click on Grant help with fees
    And I check the Other option
    And Click Update application without providing detail
    Then I should see an error telling me to enter a reason for granting help with fees
    And The application should remain ineligible
    And I should not see a message telling me the application passed by manager's decision

  Scenario: Paper evidence gives reason to override income decision
    Given I have completed an ineligible paper application - income too high
    When I click on Grant help with fees
    And I check the Paper evidence option
    And I Click Update application
    Then I should see a message telling me the application passed by manager's decision
    And The application should become eligible

  Scenario: Details are included with Other reason to override
    Given I have completed an ineligible paper application - income too high
    When I click on Grant help with fees
    And I check the Other option
    And Click Update application after providing detail
    Then I should see a message telling me the application passed by manager's decision
    And The application should become eligible

  Scenario: Your delivery manager has allowed discretion with this application
    Given I have completed an ineligible paper application - income too high
    When I click on Grant help with fees
    And I check the delivery manager option
    And I Click Update application
    Then I should see a message telling me the application passed by manager's decision
    And The application should become eligible

  Scenario: You want to check if the applicant is receiving benefits using the DWP checker
    Given I have completed an ineligible paper application - income too high
    When I click on Grant help with fees
    And I check the DWP option
    And I Click Update application
    Then I should see a message telling me the application passed by manager's decision
    And The application should become eligible

  Scenario: You try to override an application which has failed due to high savings/investments
    Given I have completed an ineligible paper application - savings too high
    Then I should see that the application fails because of saving and investments
    And I should not be able to grant help with fees
