Feature: Benfits page

  Background: Benfits page
    Given I have started an application
    And I am on the benfits part of the application

    Scenario: Successfully answer the benfits question
      When I answer yes to the benefits question
      Then I should be asked about paper evidence