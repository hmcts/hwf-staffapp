@manual @wip

Feature: View staff

  Background: View staff
    Given I am on the staff page

    Scenario: Filter by office
      When I filter by office
      Then I see all the results for that office
    
    Scenario: Filter by activity
      When I filter by activity
      Then I see all the results for that activity

    Scenario: Change details
      When I click on change details of one of the members of staff
      Then I can change the details of that member of staff

    Scenario: Re-invite 
      When I click om re-invite
      Then I can re-invite that member of staff
