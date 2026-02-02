Feature: Rejection letter based off income / Savings

  Scenario: Paper application with income over £10000
    Given I process a paper application with high income
    Then the rejection letter should state "Your total monthly income: £10,000"

  Scenario: Online application with income over £6065
    Given I have an online application with high income
    When I process that application
    Then the rejection letter should state "Your average income for the last 3 months: £6,065"

  Scenario: Online application with income over £6230 and 4 children
    Given I have an online application with children
    When I process that application
    Then the rejection letter should state "Your average income for the last 3 months: More than £6,230"

  Scenario: Online application with saving over £16000
    Given I have an online application with big savings
    And Benefit Check is ok
    When I process that application
    Then the rejection letter should state "The applicant's savings and investments total: £16,000 or more"

  Scenario: Online application with saving over £3500
    Given I have an online application with medium savings
    And Benefit Check is ok
    When I process that application
    Then the rejection letter should state "The applicant's savings and investments total: £3,500"