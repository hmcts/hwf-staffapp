@e2e

Feature: My user dashboard

  Background: Signed in as admin
    Given I am signed in as admin

  Scenario: Generate a report
    When I look up a invalid hwf reference
    Then I should see the reference number is not recognised

  Scenario: View offices
    When I click on view office
    Then I am taken to the offices page

  Scenario: Total responses
    Then I should see all the responses by type

  Scenario: Time of day
    Then I should see checks by time of day

  Scenario: 5 day benefit check/court graphs
    When I click on court graphs under the header 5 day benefit check/court graphs
    Then I am taken to reports and graphs
    