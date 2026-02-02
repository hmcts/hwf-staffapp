Feature: Problem with evidence page

  Background: Problem with evidence page
    Given I have evidence check application
    And I am on the problem with evidence page

  Scenario: Return application when evidence has not arrived or too late
    When I submit the page with not arrived or too late
    Then I should be taken to the return letter page

  Scenario: Return application when citizen is not proceeding
    When I submit the page with citizen not proceeding
    Then I should be taken to the return letter page

  Scenario: Staff error
    When I click on staff error
    And I submit the details of the staff error
    Then I should be taken to the return letter page
    And on the processed application I can see that the reason for not being processed is staff error

  Scenario: Problem with evidence error message
    When I click on next without making a selection
    Then I should see select from one of the problem options error message
