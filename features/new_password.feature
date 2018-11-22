@e2e

Feature: New password

Background: Help with Fees staff application new password page
  Given I am on the Help with Fees staff application new password page

  Scenario: Get a new password
    When I sumbit my email address
    Then I should receive confirmation instructions via email

  Scenario: Did not receive confirmation instructions
    When I click on did not receive confirmation instructions
    # taken where?
    Then I am taken to