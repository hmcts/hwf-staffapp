Feature: Incomes page

  Background: Incomes page
    Given I have started an application
    And I am on the incomes part of the application

    Scenario: Yes the applicant financially supports children
      When I answer yes to does the applicant financially support any children
      And I submit the total number of children
      And I submit the total monthly income
      Then I am on the summary page

    Scenario: No the applicant does not financially support children
      When I answer no to does the applicant financially support any children
      And I submit the total monthly income
      Then I am on the summary page

    Scenario: Enter number of children and total monthly income
      When I answer yes to does the applicant financially support any children
      But I do not fill in the number of children or total monthly income
      Then I should see enter number of children error message
      And I should see enter total monthly income error message