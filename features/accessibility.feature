Feature: Accessibility

  Background: Accessibility admin pages
    Given I successfully sign in as admin

    @javascript @accessibility
    Scenario: Admin dashboard page
      When I visit the admin dashboard page
      Then the page should be axe clean

    @javascript @accessibility
    Scenario: Admin profile page
      When I am on the change details page
      Then the page should be axe clean

    @javascript @accessibility
    Scenario: Admin office page
      When I can view office details
      Then the page should be axe clean

    @javascript @accessibility
    Scenario: Admin staff page
      When I can view staff
      Then the page should be axe clean

    @javascript @accessibility
    Scenario: Admin edit banner page
      When I can edit banner
      Then the page should be axe clean

    @javascript @accessibility
    Scenario: Admin dwp message page
      When I can view staff DWP warning message page
      Then the page should be axe clean
      
    @javascript @accessibility
    Scenario: Admin staff guides page
      When I can view staff guides
      Then the page should be axe clean

    # @javascript @accessibility
    # Scenario: Admin old letter templates page
    #   When I can view old letter templates
    #   Then the page should be axe clean

    @javascript @accessibility
    Scenario: Admin new letter templates page
      When I can view new letter templates
      Then the page should be axe clean

    @javascript @accessibility
    Scenario: Admin generate reports page
      When I click on generates reports
      Then I should be on the generate reports page
      Then the page should be axe clean