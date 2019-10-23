Feature: Admin navigation

  Background: Signed in as admin
    Given I successfully sign in as admin

  Scenario: Feedback
    When I click on feedback
    Then I am taken to the feedback received page
