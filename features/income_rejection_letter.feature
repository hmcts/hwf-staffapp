Feature: Rejection letter based off income

  Scenario: Paper application with income over £10000
    Given I process a paper application with high income
    When I enter input as £10000
    Then the rejection letter should state "Your income total: £10,000.00"

  Scenario: Online application with income over £6065
    Given I have an online application with high income
    When I process that application
    Then the rejection letter should state "Your income total: £6,065"

  Scenario: Online application with income over £6065 and 4 children
    Given I have an online application with children
    When I process that application
    Then the rejection letter should state "Your income total: £6,065 or more"