Feature: User navigation
  
  Background: Logged in as a user
    Given I successfully sign in as a user

  @manual @wip
  Scenario: View profile
    When I click on view profile
    Then I am taken to my details

  @manual @wip
  Scenario: View staff guides
    When I click on staff guides
    Then I am taken to staff guides

  Scenario: Feedback
    When I click on feedback
    Then I am taken to your feedback page

  @manual @wip
  Scenario: Letter templates
    When I click 

  Scenario: Sign out
    When I click on sign out
    Then I am taken to the sign in page

  @manual @wip
  Scenario: Unable to view office
    Then I should not be able to navigate to office details

  @manual @wip
  Scenario: Unable to edit banner
    Then I should not be able to navigate to edit banner

  @manual @wip
  Scenario: Unable to view staff
    Then I should not be able to navigate to the staff page

  @manual @wip
  Scenario: Unable to edit DWP message
    Then I should not be able to navigate to the DWP warning message page
