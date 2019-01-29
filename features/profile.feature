@manual @wip

Feature: View profile

  Background: Help with Fees staff application profile page
    Given I am on the Help with Fees staff application profile page

    Scenario: Staff details
      Then I should see my details

    Scenario: Change details
      When I click on change details
      Then I should be able to change my details

    Scenario: Change your password
      When I clink on change your password
      Then I am taken to change password page
    
    Scenario: Back to list of staff
      When I click on back to list of staff
      Then I am taken to user page