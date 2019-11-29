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

  Scenario: Staff error
    When I submit the page with staff error
    Then I should be taken to the return letter page
  
  Scenario: Problem with evidence error message
    When I click on next without making a selection
    Then I should see select from one of the options error message
