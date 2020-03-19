Feature: Staff

  Background: Admin on the staff page
    Given I am admin on the staff page

    Scenario: Filter by office
      When I filter by office
      Then I see all the results for that office
    
    Scenario: Filter by activity
      When I filter by activity
      Then I see all the results for that activity

    Scenario: Change details
      When I click on change details of one of the members of staff
      And I change the member of staff to a reader
      Then I can see that the user is a reader
