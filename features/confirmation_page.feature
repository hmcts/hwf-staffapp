Feature: Confirmation page

  Background: Confirmation page
    Given I have processed an application
    And I am on the confirmation page

    Scenario: Back to start
      When I click on back to start
      Then I should be taken back to my dashboard
      And I should see my processed application in your last applications
