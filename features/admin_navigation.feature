Feature: Admin navigation

  Background: Signed in as admin
    Given UCD changes are active
    Given I successfully sign in as admin

    Scenario: View profile
      Then I can view my profile

    Scenario: View office
      Then I can view office details

    Scenario: View staff
      Then I can view staff

    Scenario: Edit banner
      Then I can edit banner

    Scenario: DWP message
      Then I can view staff DWP warning message page

    Scenario: Staff guides
      Then I can view staff guides

    Scenario: Feedback
      Then I can view feedback received

    Scenario: Letter templates
      Then I can view letter templates

    Scenario: Sign out
      When I sign out
      Then I am taken to the sign in page
