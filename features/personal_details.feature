Feature: Personal details page

  Background: Personal details page
    Given UCD changes are active
    Given I have started an application
    And I am on the personal details part of the application

    Scenario: Required information
      When I click on next without answering any questions
      Then I should see that I must fill in my last name
      And I should have to enter my date of birth
      And I should have to enter my marital status

    Scenario: Last name is too short
      When I fill in the form with a last name with one letter
      Then I should see error message last name is too short

    Scenario: Date of birth blank
      When I leave the date of birth blank
      Then I should see the invalid date of birth error message

    Scenario: Cannot be under 0 years old
      When I submit a date that makes the applicant born in the future
      Then I should see that the applicant cannot be under 16 years old error message

    Scenario: Enter a home office reference number in the wrong format
      When I enter a home office reference number in the wrong format
      Then I should see enter a home office reference number in the correct format error message

    Scenario: Successfully submit my required personal details
      When I successfully submit my required personal details
      Then I should be taken to the application details page

    Scenario: Before you start
      Then I should see before you start advice
      And I see that I should check that the applicant is not
      And I see that I should check the fee
      And I see that I should look for a national insurance number
      And I see more information about home office numbers
      And I see that I should check the status of the applicant