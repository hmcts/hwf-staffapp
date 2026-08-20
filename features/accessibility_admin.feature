@javascript @accessibility
Feature: Accessibility of admin pages

  Background: Signed in as admin
    Given I successfully sign in as admin

  Scenario: Admin dashboard
    When I visit the dashboard page
    Then I am taken to my admin dashboard
    And I should see all the responses by type graph
    And I should see checks by time of day graph
    And the "Admin dashboard" page should meet accessibility standards

  Scenario: Offices
    When I click on view office
    Then I am taken to the offices page
    And the "Offices list" page should meet accessibility standards
    When I can view office details
    And the "Office details" page should meet accessibility standards

  Scenario: Staff
    Given there are other members of staff
    When I can view staff
    Then the "Staff list" page should meet accessibility standards
    When I open the details of another member of staff
    Then the "Staff member details" page should meet accessibility standards
    When I open the change details page for that member of staff
    Then the "Change staff member details" page should meet accessibility standards

  Scenario: Edit banner
    When I can edit banner
    Then the "Edit notification banner" page should meet accessibility standards

  Scenario: DWP message
    When I can view staff DWP warning message page
    Then the "Choose the DWP message" page should meet accessibility standards

  Scenario: Feedback received
    Given a user has left feedback
    When I can view feedback received
    Then I should see the feedback received
    And the "Feedback received" page should meet accessibility standards

  Scenario: Management information reports
    When I click on generates reports
    Then I should be on the generate reports page
    And the "Management information reports" page should meet accessibility standards

  Scenario: Finance aggregated report
    Given I am on the finance aggregated report page
    Then the "Finance aggregated report" page should meet accessibility standards

  Scenario: Finance transactional report
    Given I am on the finance transactional report page
    Then the "Finance transactional report" page should meet accessibility standards

  Scenario: Public submissions report
    Given I am on the reports page
    When I click on public submissions
    Then I should be taken to the public submissions page
    And the "Public submissions report" page should meet accessibility standards

  Scenario: Raw data extract report
    Given I am on the reports page
    When I click on raw data extract
    Then I should be taken to the raw data extract page
    And the "Raw data extract report" page should meet accessibility standards

  Scenario: Graphs
    Given I am on the reports page
    When I click on graphs
    Then I should be taken to the graphs page
    And the "Benefit check graphs" page should meet accessibility standards

  Scenario: Guides and letter templates
    Given I can view staff guides
    And the "Staff guides" page should meet accessibility standards
    Then I can view letter templates
    And the "Old scheme letter templates" page should meet accessibility standards
    Then I can view new letter templates
    And the "New scheme letter templates" page should meet accessibility standards

  Scenario: Appeals letter templates
    Then I can view appeals letter templates
    And the "Appeals letter templates" page should meet accessibility standards

  Scenario: LCEP letter templates
    Then I can view LCEP letter templates
    And the "LCEP letter templates" page should meet accessibility standards
