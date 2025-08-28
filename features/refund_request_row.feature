Feature: Refund request row

  Background: Refund request row
    Given UCD changes are active

  Scenario: Online application with refund
    Given An applicant has submitted an online application where fee has been paid
    And I successfully sign in as a user
    When I process the online application to the check details page
    Then There will be a row under the Application details section labelled Refund request Yes

  Scenario: Online application with no refund
    Given An applicant has submitted an online application where fee has not been paid
    And I successfully sign in as a user
    When I process the online application to the check details page
    Then There will be a row under the Application details section labelled Refund request No

  Scenario: Paper application with refund
    Given I successfully sign in as a user
    When I process a paper application where fee has been paid to the check details page
    Then There will be a row under the Application details section labelled Refund request Yes

  Scenario: Paper application waiting for evidence with no refund (visit via Waiting for evidence)
    Given there is an application waiting for evidence where fee has not been paid
    When I go to the waiting for evidence application
    Then There will be a row under the Application details section labelled Refund request No

  Scenario: Paper application part payment with no refund (end of processing)
    Given I successfully sign in as a user
    When I process a part payment paper application where fee has been paid to the check details page
    Then There will be a row under the Application details section labelled Refund request Yes
