@manual

Feature: Before you start

  Background: Navigating to before you start 
    Given I am on the personal details page

   Scenario: Check the applicant is not
     Then I should see check the applicant is not list with a link to not eligible

  Scenario: Check the fee
    Then I should see check the fee with a link to not eligible

  Scenario: National in
     