@wip 

Feature: Application details page

  Background: Application details page
    Given I have started an application
    And I am on the application details part of the application
    
    Scenario: Successfully submit my required personal details
      When I successfully submit my required application details
      Then I should be taken to savings and investments page
