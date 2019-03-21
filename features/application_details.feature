Feature: Application details page

  Background: Application details page
    Given I have started an application
    And I am on the application details part of the application
    
    Scenario: Successfully submit my required personal details
      When I successfully submit my required application details
      Then I should be taken to savings and investments page

    Scenario: Leaving form number blank
      When I submit the form without a number
      Then I should see enter a valid form number error message

    Scenario: Entering a help with fees form number
      When I submit the form with a help with fees form number 'COP44A'
      Then I should see you entered the help with fees form number error message
      And I submit the form with a help with fees form number 'EX160'
      Then I should see you entered the help with fees form number error message