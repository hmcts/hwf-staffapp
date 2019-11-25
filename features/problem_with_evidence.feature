Feature: Problem with evidence page

  Background: Problem with evidence page
    Given I successfully sign in as a user
    And I am on the problem with evidence page

  Scenario: What is the problem with the evidence
    When I successfully submit one of the problems
    Then I am taken to the rejection letter page

  Scenario: Problem with evidence error message
    When I click on next without making a selection
    Then I should see select from one of the options error message

  Scenario: Staff error
    When I click on staff error
    And I submit the details of the staff error
    Then I am taken to the rejection letter page
    And on the processed application I can see that the reason for not being processed is staff error
