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

    Scenario: Date of birth blank
      When I leave the date of birth blank
      Then I should see the invalid date of birth error message

    Scenario: Cannot be under 16 years old
      When I submit a date that makes the applicant under 16 years old
      Then I should see that the applicant cannot be under 16 years old error message

    Scenario: Successfully submit my required personal details
      When I successfully submit my required personal details
      Then I should be taken to the application details page
