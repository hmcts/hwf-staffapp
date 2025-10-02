@reports

Feature: Generate report page

  Background: Signed in as admin
    Given UCD changes are active
    Given I successfully sign in as admin

    @wip @manual
    # download times out on travis
    Scenario: Successfully download finance aggregated report
      Given I am on the finance aggregated report page
      When I enter a valid date for finance aggregated reports
      Then a finance aggregated report is downloaded

    Scenario: Filters
      Given I am on the finance aggregated report page
      Then I can filter by business entity code
      And I can filter by jurisdiction
      And I can filter by application type
      And I can filter refund cases
  
    Scenario: Generate finance aggregated report without dates
      Given I am on the finance aggregated report page
      When I try and generate a report without entering dates
      Then I should see enter dates error message

    @wip @manual
    # download times out on travis
    Scenario: Successfully download finance transactional report
      Given I am on the finance transactional report page
      When I enter a valid date for finance transactional reports
      Then a finance transactional report is downloaded

    Scenario: Invalid range dates for finance transactional report
      Given I am on the finance transactional report page
      When I enter a date range that exceeds two years
      Then I should see date range exceeds two years error message
