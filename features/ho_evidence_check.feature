Feature: Evidence check on home office number

  Background: Applicant with home office number
    Given the applicant has a home office number

  Scenario: Refund application with same home office number
    And the first application is a refund application
    When a second application is processed with the same home office number
    Then the first application will be processed
    But the second application will require evidence
