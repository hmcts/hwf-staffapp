Feature: Admin dashboard

  Background: Signed in as admin
    Given UCD changes are active
    Given I successfully sign in as admin

  Scenario: Searching for application
    When I search for an application using an invalid hwf reference
    Then I see an error message saying no results found

  Scenario: Generate reports
    When I click on generates reports
    Then I am taken to the reports page

  Scenario: View offices
    When I click on view office
    Then I am taken to the offices page

  Scenario: Total responses
    Then I should see all the responses by type graph

  Scenario: Time of day
    Then I should see checks by time of day graph

  Scenario: Court graphs
    When I click on Court graphs
    Then I am taken to Court graphs page
    