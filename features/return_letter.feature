Feature: Return letter

  Background: Return letter
    Given UCD changes are active
    Given I have evidence check application

  Scenario: Not arrived or too late letter template
    And I am on the return letter page after selecting not arrived or too late
    Then I should see next steps information for not received
    And I should see evidence has not arrived or too late letter template

  Scenario: Citizen not proceeding letter template
    And I am on the return letter page after selecting citizen not proceeding
    Then I should see next steps information for citizen not proceeding
    And I should see a not proceeding application letter template

  Scenario: Staff error letter template
    When I am on the return letter page after selecting staff error
    And I should see no letter template

  Scenario: Back to start
    When I am on the return letter page after selecting citizen not proceeding
    And I click on Back to start
    Then I should be taken back to my dashboard

  Scenario: Back to list
    When I am on the return letter page after selecting citizen not proceeding
    And I click on Back to list
    Then I am taken to the waiting for evidence page
    And I should see there are no applications waiting for evidence
