Feature: Evidence check on home office number

  Scenario: Refund application with same home office number
    Given I process applications with waiting evidence check where the applicant has a home office number
    When a second application is processed with the same home office number
    Then the first application will be waiting
    But the second application will require evidence

