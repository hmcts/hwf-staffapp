Feature: Reason for rejecting the evidence

  Background: Reason for rejecting the evidence page
    Given I have evidence check application
    And I am on reason for rejecting the evidence page

  Scenario: Multiple reasons for rejecting the evidence
    When I successfully submit multiple reasons
    Then I am taken to the summary page
    And I should see my reasons for evidence on the summary page

  Scenario: Single reason for rejecting the evidence
    When I successfully submit a single reason
    Then I am taken to the summary page
    And I should see my reason for evidence on the summary page

  Scenario: Reason for rejecting the evidence error message
    When I click on next without making a selection
    Then I should see select from one of the options error message
