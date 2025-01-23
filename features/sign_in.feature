Feature: Sign in page

  Background: Navigating to the sign in page
    Given I am on the Help with Fees staff application home page
    When I am not signed in
    Then I am redirected to the sign in page

    Scenario: Successful sign in as a user
      When I successfully sign in as a user
      Then I am taken to my user dashboard

    Scenario: Successful sign in and sign out as a user
      When I successfully sign in as a user
      Then I am taken to my user dashboard
      When I sign out
      Then I should be on sign in page
      And I should not see invalid email or password error message

    Scenario: Successful sign in as an admin
      When I successfully sign in as admin
      Then I am taken to my admin dashboard

    Scenario: Successful sign in as a read only user
      When I successfully sign in read only user
      Then I am taken to my read only user dashboard

    Scenario: Invalid credentials
      When I attempt to sign in with invalid credentials
      Then I should see invalid email or password error message

    Scenario: Get help - forgot password
      When I see forgot your password guidance
      And I click on the link get a new password
      Then I am taken to get a new password page

    Scenario: Get help - don't have an account
      And I see get help
      Then I should see under don't have an account that I need to contact my manager

    Scenario: Get help - having technical issues
      When I see having technical issues
      Then I should be able to send an email to help with fees support
