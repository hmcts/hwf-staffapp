Feature: Find an application

  Background: Find an application
    Given UCD changes are active

  Scenario: Find an application by valid hwf reference - single result
    Given I am signed in as a user that has processed an application
    When I search for an application using a valid hwf reference
    Then I see that application under search results
    And that there is one result for my office

  Scenario: Find an application by last name - multiple results
    Given I am signed in as a user that has processed multiple applications
    When I search for an application using a last name
    Then I should see a list of the results for that last name
    And that there are two results for my office

  Scenario: Find an application by full name
    Given I am signed in as a user that has processed multiple applications
    When I search for an application using a full name
    And there is a single result for that full name
    Then I should see the result for that full name

  Scenario: Find an application by case number
    Given I am signed in as a user that has processed an application
    When I search for an application using a case number
    Then I should see there is a single result for that case number

  Scenario: Find an application by national insurance number
    Given I am signed in as a user that has processed an application
    When I search for an application using a national insurance number
    Then I should see there is a single result for that national insurance number
    But the national insurance number is not displayed in the list of results

  Scenario: Result from another office
    Given a user has processed an application
    And I am signed in as a user from a different office
    When I search for the application processed by the different office
    Then I am told that the application has been processed by another office
    And I am not able to view that application
  
  Scenario: Sort search results
    Given I have a list of search results
    Then I can sort by reference
    And I can sort by entered
    And I can sort by first name
    And I can sort by last name
    And I can sort by case number
    And I can sort by fee
    And I can sort by remission
    And I can sort by completed

  Scenario: Invalid search
    Given I am signed in as a user that has processed an application
    When my search is invalid
    Then I should see reference number is not recognised error message

  Scenario: Search is blank
    Given I am signed in as a user that has processed an application
    When I search leaving the input box blank
    Then I get the cannot be blank error message
  
  Scenario: Pagination
    Given I have more than 20 search results
    Then I see that it is paginated by 20 results per page
    And I can navigate forward a page
    And I can navigate back a page