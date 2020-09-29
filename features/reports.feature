@reports

Feature: Reports page

  Background: Reports page
    Given I successfully sign in as admin
    And I am on the reports page

    Scenario: Finance aggregated report
      When I click on finance aggregated report
      Then I should be taken to finance aggregated report page

    Scenario: Finance transactional report
      When I click on finance transactional report
      Then I should be taken to finance transactional report page

    Scenario: Graphs
      When I click on graphs
      Then I should be taken to the graphs page

    Scenario: Public submissions
      When I click on public submissions
      Then I should be taken to the public submissions page

    Scenario: Letters
      When I click on letters
      Then I should be taken to the letters page

    Scenario: Raw data extract
      When I click on raw data extract
      Then I should be taken to the raw data extract page

    Scenario: Analytic services data extract
      When I click on analytic services data extract
      Then I should be taken to the analytic services data extract page
