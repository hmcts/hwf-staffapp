@javascript @accessibility
Feature: Accessibility

  Background: Accessibility admin pages
    Given I successfully sign in as admin

    Scenario: Admin dashboard page
      When I visit the admin dashboard page
      Then the page should be axe clean

    Scenario: Admin profile page
      When I am on the change details page
      Then the page should be axe clean

    Scenario: Admin office page
      When I can view office details
      Then the page should be axe clean

    Scenario: Admin staff page
      When I can view staff
      Then the page should be axe clean

    Scenario: Admin edit banner page
      When I can edit banner
      Then the page should be axe clean

    Scenario: Admin dwp message page
      When I can view staff DWP warning message page
      Then the page should be axe clean

    Scenario: Admin staff guides page
      When I can view staff guides
      Then the page should be axe clean

    Scenario: Admin feedback page
      When I can view feedback received
      Then the page should be axe clean

    # Scenario: Admin old letter templates page
    #   When I can view old letter templates
    #   Then the page should be axe clean

    Scenario: Admin new letter templates page
      When I can view new letter templates
      Then the page should be axe clean

    Scenario: Admin generate reports page
      When I click on generates reports
      Then I should be on the generate reports page
      Then the page should be axe clean

    Scenario: Admin offices page
      When I click on view office
      Then I am taken to the offices page
      Then the page should be axe clean
    
    Scenario: Admin profile edit page
      When I am admin on the staff page
      When I click on change details of a user
      Then the page should be axe clean

    Scenario: Admin finance aggregated report page
      When I am on the finance aggregated report page
      Then the page should be axe clean