Feature: Summary page

  Background: Summary page
    Given I have completed an application
    And I am on the summary page

    Scenario: Successfully submit my application
      When I successfully submit my application
      Then I should be taken to the confirmation page

    Scenario: Displays benefit summary
      When I see benefit summary 
      Then I should see I have declared benefits in this application
      And I have provided the correct evidence
