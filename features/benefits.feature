Feature: Benefits page

  Background: Benefits page
    Given I have started an application
    And I am on the benefits part of the application

    Scenario: Yes the applicant is receiving benefits
      When I answer yes to the benefits question
      Then I should be asked about paper evidence

    Scenario: No the applicant is not receiving benefits
      When I answer no to the benefits question
      Then I should be taken to the children page
