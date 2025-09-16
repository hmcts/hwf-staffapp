Feature: Staff

  Background: Staff
    Given UCD changes are active

    Scenario: Filter by office
      Given I am admin on the staff page
      When I filter by office
      Then I see all the results for that office
    
    Scenario: Filter by activity
      Given I am admin on the staff page
      When I filter by activity
      Then I see all the results for that activity

    Scenario: Add staff
      Given I am admin on the staff page
      When I click on add staff
      Then I am taken to the send invitation page

    Scenario: Deleted staff
      Given I am admin on the staff page
      When I click on deleted staff
      Then I am taken to the deleted staff page

    Scenario: Office filter disabled for manager
      Given I am manager on the staff page
      Then the office filter is disabled
