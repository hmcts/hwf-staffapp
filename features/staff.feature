Feature: View staff

  Background: View staff
    Given I am signed in as admin on the staff page

    Scenario: Add staff
      When I click on add staff
      Then I am taken to the send invitation page

    Scenario: Deleted staff
      When I click on deleted staff
      Then I am taken to the deleted staff page

    Scenario: Filter by office
      When I filter by office
      Then I see all the results for that office
    
    Scenario: Filter by activity
      When I filter by activity
      Then I see all the results for that activity

    Scenario: Change details
      When I click on change details of one of the members of staff
      And I change the details of that member of staff
      Then I am taken to the staff details page
      And I can see the details have been changed
