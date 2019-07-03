Feature: Ask a manager page

    Background: Ask a manager page
      Given I am on the ask a manager page

    Scenario: Successfully submit manager name
      When I successfully submit a manager name
      Then I am taken to the savings and investments page
   
   