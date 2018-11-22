@e2e

Feature: Sign in page

  Background: Navigating to the sign in page
    Given I am on the Help with Fees staff application home page
    When I am not signed in
    Then I am redirected to the sign in page

    Scenario: Successful sign in as a user
      When I successfully sign in as a user
      Then I am taken to my user dashboard

    Scenario: Successful sign in as an admin
      When I successfully sign in as admin
      Then I am taken to my admin dashboard

    Scenario: Successful sign in as an manager
      When I successfully sign in a manager
      Then I am taken to my manager dashboard

    Scenario: Invalid credentials
      When I attempt to sign in with invalid credentials
      Then I should see invalid email or password error message

    Scenario: Forgot your password
      When I click on forgot your password
      Then I am taken to get a new password page

    Scenario: Get help
      Then I should see forgot your password with get a new password link
      And I should see do not have an account
      And I should be able to email support if I am having technical issues
