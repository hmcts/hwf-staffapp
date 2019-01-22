Feature: Savings and investments page

  Background: Savings and investments page
    Given I have started an application
    And I am on the savings and investments part of the application

    Scenario: Successfully submit less than £3000
      When I successfully submit less than £3000
      Then I should be taken to the benefits page

    Scenario: Successfully submit more than £3000
      When I click on more than £3000
      And I submit how much they have
      Then I should be taken to the summary page
