Feature: Rejection letter based off income

  Scenario: Paper application with income over £10000
    Given I process a paper application with fee of £100
    When I enter input as £10000
    Then the rejection letter should state "Your income total: £10,000.00"

  Scenario: Online application with income over £6065
    Given I have an online application with fee of £100 and income of 6065
    When I process that application
    Then the rejection letter should state "Your income total: £6,065"