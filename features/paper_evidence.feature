Feature: Paper evidence page

  Background: Paper evidence page
    Given I have started an application
    And I am on the paper evidence part of the application

    Scenario: Successfully submit my required paper evidence details
      When I successfully submit my required paper evidence details
      Then I should be taken to the summary page