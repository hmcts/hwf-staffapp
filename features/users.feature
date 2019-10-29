Feature: Users

    Background: Staff page
      Given I successfully sign in as admin
      And I am on the staff page

    Scenario: Add staff
      When I click on the add staff link
      Then I should be taken to the send invitation page

    Scenario: Deleted users
      When I click on the deleted users link
      Then I should be taken to the deleted staff page
