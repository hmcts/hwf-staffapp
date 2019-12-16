Feature: Return letter

  Scenario: Not arrived or too late letter template
    Given I am on the return letter page after selecting not arrived or too late
    Then I should see next steps information for not received
    And I should see evidence has not arrived or too late letter template

  Scenario: Citizen not proceeding letter template
    Given I am on the return letter page after selecting citizen not proceeding
    Then I should see next steps information for citizen not proceeding
    And I should see a not proceeding application letter template

  Scenario: Staff error letter template
    Given I am on the return letter page after selecting staff error
    And I should see no letter template

  Scenario: Finish
    Given I am on the return letter page after selecting citizen not proceeding
    When I click on finish
    Then I should be taken back to my dashboard