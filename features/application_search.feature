Feature: Search application

  Background: Signed in as a user
    
  Scenario: Search application by valid hwf reference - single result
    Given I am signed in as a user that has processed an application
    When I search for an application using a valid hwf reference
    Then I see that application under search results

  Scenario: Search application by name - multiple results
    Given I am signed in as a user that has processed multiple applications
    When I search for an application by name
    And there are multiple results for that name
    Then I should see a list of the results for that name

  Scenario: Search application by case number
    Given I am signed in as a user that has processed an application
    When I search for an application using a case number
    Then I should see a list of the results with that case number

  Scenario: Invalid search
    Given I am signed in as a user that has processed an application
    When my search is invalid
    Then I should see reference number is not recognised error message

  Scenario: Search is blank
    Given I am signed in as a user that has processed an application
    When I search leaving the input box blank
    Then I get the cannot be blank error message
    