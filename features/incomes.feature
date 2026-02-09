Feature: Incomes page

  Background: Incomes page
    Given I have started an application
    And I am on the income part of the application

    Scenario: I submit total monthly income
      When I submit the total monthly income
      Then I am on the declaration page

    Scenario: Do not enter total monthly income
      When I do not submit the total monthly income
      And I should see enter total monthly income error message