Feature: Personal details page

  Background: Personal details page
    Given I have started an application
    And I am on the personal details part of the application

    @manual @wip
    Scenario: Required information
      When I click on next without answering any questions
      Then I should see that I must fill in my last name
      And I should have to enter my date of birth
      And I should have to enter my marital status

    @manual @wip
    Scenario: Last name is too short
      When I fill in the form with a last name with one letter
      Then I should see error message last name is too short

    @manual @wip
    Scenario: Invalid date of birth
      When I enter an invalid date of birth
      Then I should see the invalid date of birth error message

    Scenario: Successfully submit my required personal details
      When I successfully submit my required personal details
      Then I should be taken to the application details page
