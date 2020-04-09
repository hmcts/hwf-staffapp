Feature: Incomes page

  Background: Incomes page
    Given I have started an application
    And I am on the incomes part of the application

    Scenario: Yes the applicant financially supports children
      When I answer yes to does the applicant financially support any children
      And I submit the total number of children
      And I submit the total monthly income
      Then I should be taken to the summary page

    Scenario: No the applicant does not financially support children
      When I answer no to does the applicant financially support any children
      And I submit the total monthly income
      Then I should be taken to the summary page
