@manual

Feature: Notification banner

  Background: Navigate to edit notification banner
    Given I am on the edit notification page

  Scenario: Add notification banner
    When I add a message
    And I check show on admin homepage
    And I click on save changes
    Then I should see your changes have been saved message
    And I should see the notification on my homepage

  Scenario: Remove notification banner
    When I uncheck show on admin homepage
    And I click on save changes
    Then I should see your changes have been saved message
    And I should not see the notification on my homepage

    