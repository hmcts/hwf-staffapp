@javascript @accessibility
Feature: Accessibility of public facing pages

  Scenario: Sign in page
    Given I am on the Help with Fees staff application home page
    When I am not signed in
    Then the "Sign in" page should meet accessibility standards
  
  Scenario: Sign in page after error
    Given I am on the Help with Fees staff application home page
    When I attempt to sign in with invalid credentials
    Then I should see invalid email or password error message
    And the "Sign in - rejected credentials" page should meet accessibility standards

  Scenario: Get a new password page
    Given I am on the Help with Fees staff application home page
    When I am not signed in
    And I click on forgot your password
    Then I am taken to get a new password page
    And the "Get a new password" page should meet accessibility standards

  Scenario: Accessibility statement
    Given I am on the Help with Fees staff application home page
    When I click on the accessibility link in the footer
    Then I am on the accessibility statement page
    And the "Accessibility statement" page should meet accessibility standards
