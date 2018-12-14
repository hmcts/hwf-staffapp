@manual

Feature: Personal details

  Background: Personal details page
    Given I am logged in as a user
    When I start a new application
    Then I am taken to the personal details page

    Scenario: Required information
      When I click on next without answering any questions
      Then I should see that I must fill in my last name
      And I should have to enter my date of birth
      And I should have to enter my marital status

    Scenario: Last name is too short
      When I fill in the form with a last name with one letter
      Then I should see error message last name is too short

    Scenario: Invalid date of birth
      When I enter an invalid date of birth
      Then I should see the invalid date of birth error message

    Scenario: Successfully fill in personal details
      When I successfully fill in my personal details page
      Then I should be taken to the application details page
