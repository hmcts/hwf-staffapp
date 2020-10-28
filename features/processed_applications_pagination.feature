Feature: Pagination on Processed applications page

  Background: Signed in and many applications on Processed applications page
    Given I am signed in as a user that has 50 processed applications
    And I click on processed applications
    And I click 15 per page

  Scenario: Next page and Previous page functionality
    When I click Next page button
    And I click Previous page button
    Then I should be on page 1

  Scenario: Go directly to last page from first page
    When I click on the number representing the last page
    Then I should be on page 4

  Scenario: Go directly to first page from last page
    When I click on the number representing the last page
    And I click on the number representing the first page
    Then I should be on page 1
