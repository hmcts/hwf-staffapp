@e2e

Feature: Users

    Scenario: Add user
      Given I am signed in as admin
      And I am on the users page
      When I successfully add a new user
      Then they should get an invitation via an email

    Scenario: Invitation received
      Given I have received an email invitation
      When I click on the link
      Then ....

    
      

