Feature: Ask a manager page

    Background: Ask a manager page
      Given I am on the ask a manager page

    Scenario: Successfully submit manager name
      When I successfully submit a manager name
      Then I am taken to the savings and investments page

    Scenario: Manager name error message
      When I click on next without supplying a manager name
      Then I should see enter manager name error message

    Scenario: Manager name first name only
      When I click on next after only supplying manager first name
      Then I should see enter manager first name error message

    Scenario: Manager name last name only
      When I click on next after only supplying manager last name
      Then I should see enter manager last name error message