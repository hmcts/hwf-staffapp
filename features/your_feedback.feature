Feature: Your feedback page

  Background: Your feedback page
    Given I successfully sign in as a user
    And I am on your feedback page

  Scenario: Urgent question
    Then I can email if I have an urgent question or something isn't working

  Scenario: Your feedback
    When I successfully submit my feedback
    Then I should be taken to my dashboard
    And I should see your feedback has been recorded notification

  Scenario: Error Message for empty feedback form
    When I click on Send feedback
    Then I should see an error summary message
    And I should see a rating error
