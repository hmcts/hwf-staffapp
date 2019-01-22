@manual @wip

Feature: User navigation
  
  Background: Logged in as a user
    Given I am logged in as a user

  Scenario: View profile
    When I click on view profile
    Then I am taken to my details

  Scenario: View staff guides
    When I click on staff guides
    Then I am taken to staff guides

  Scenario: Letter templates
    When I click 

  Scenario: Sign out
    When I click on sign out
    Then I am taken to the sign in page

  Scenario: Unable to view office
    Then I should not be able to navigate to office details

  Scenario: Unable to edit banner
    Then I should not be able to navigate to edit banner

  Scenario: Unable to view staff
    Then I should not be able to navigate to the staff page

  Scenario: Unable to edit DWP message
    Then I should not be able to navigate to the DWP warning message page

