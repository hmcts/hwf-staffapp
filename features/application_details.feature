Feature: Application details page

  Background: Application details page
    Given UCD changes are active
    Given I have started an application
    And I am on the application details part of the application
    
    Scenario: Successfully submit my required application details
      When I successfully submit my required application details
      Then I should be taken to savings and investments page

    Scenario: Leaving form number blank
      When I submit the form without a form number
      Then I should see enter a valid form number error message
    
    Scenario: Leaving fee blank
      When I submit the form without a fee amount
      Then I should see enter a fee error message

    Scenario: Fee is £20,000 or over
      When I submit the form with a fee £20,000 or over
      Then I should see error message telling me that the fee needs to be below £20,000

    Scenario: Fee is £10,001 - £19,999
      When I submit the form with a fee £10,001 - £19,999
      Then I should be taken to ask a manager page

    Scenario: Entering a help with fees form number
      When I submit the form with a help with fees form number 'COP44A'
      Then I should see you entered the help with fees form number error message
      And I submit the form with a help with fees form number 'EX160'
      Then I should see you entered the help with fees form number error message