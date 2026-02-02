Feature: Staff profile

  Scenario: Change user details page
      Given I successfully sign in as a user
      And I am on the change details page
      When I change my details
      And I am on my profile page
      Then I can see my profile has been changed
