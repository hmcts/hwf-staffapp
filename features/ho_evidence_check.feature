Feature: Evidence check on home office number

  Scenario: Refund application with same home office number
    Given I process applications where the applicant has a home office number
    When a second application is processed with the same home office number
    Then the first application will be processed
    But the second application will require evidence
