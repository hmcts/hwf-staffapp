Feature: Summary page

  Background: Summary page
    Given I have completed an application
    And I am on the summary page

    Scenario: Successfully submit my application
      When I successfully submit my application
      Then I should be taken to the confirmation page
