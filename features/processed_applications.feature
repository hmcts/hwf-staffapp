Feature: Processed applications

  Background: Processed applications page
    Given I am signed in as a user that has processed multiple applications
    When I click on a processed application

    Scenario: Open an application
      Then I should be taken to that application

    Scenario: Displays benefit information
      Then I should see declared benefits in this application

    Scenario: Result
      When I look at the result on the processed application page
      Then I should see the result for savings on the processed application page
      And I should see the result for benefits on the processed application page
