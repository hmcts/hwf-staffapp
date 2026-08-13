@javascript @accessibility
Feature: Accessibility

  Background: Accessibility admin pages
    Given I successfully sign in as admin

    Scenario: Admin dashboard page
      When I visit the dashboard page
      And I take a screenshot of the page
      Then the page should be axe clean excluding "#chart-1" according to: wcag2aa

    Scenario: Admin profile page
      When I am on my profile page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin office page
      When I can view office details
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin staff page
      When I can view staff
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin edit banner page
      When I can edit banner
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin dwp message page
      When I can view staff DWP warning message page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin staff guides page
      When I can view staff guides
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin feedback page
      When I can view feedback received
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin old letter templates page
      When I can view letter templates
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin new letter templates page
      When I can view new letter templates
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin generate reports page
      When I click on generates reports
      Then I should be on the generate reports page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin offices page
      When I click on view office
      Then I am taken to the offices page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
    
    Scenario: Admin profile edit page
      When I am on the change details page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin finance aggregated report page
      When I am on the finance aggregated report page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin finance transactional report page
      When I am on the finance transactional report page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin public submissions page
      When I am on the reports page
      And I click on public submissions
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: Admin raw data extract page
      When I am on the reports page
      And I click on raw data extract
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa