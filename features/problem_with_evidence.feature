Feature: Problem with evidence page

  Background: Problem with evidence page
    Given I am on the problem with evidence page

  Scenario: Return application when evidence has not arrived or too late
    When I submit the page with not arrived or too late
    Then I should be taken to the return letter page
    And I should see evidence has not arrived or too late letter template
    When I click on finish
    Then I should be taken back to my dashboard

  Scenario: Return application when citizen is not proceeding
    When I submit the page with citizen not proceeding
    Then I should be taken to the return letter page
    And I should see a not proceeding application letter template
    When I click on finish
    Then I should be taken back to my dashboard

  Scenario: Problem with evidence error message
    When I click on next without making a selection
    Then I should see select from one of the problem options error message

  Scenario: Staff error
    When I click on staff error
    And I submit the details of the staff error
    Then I am taken to the rejection letter page
    And on the processed application I can see that the reason for not being processed is staff error

  Scenario: Evidence not received
    When I submit the page with not arrived or too late
    Then I should see next steps information for rejection letter

