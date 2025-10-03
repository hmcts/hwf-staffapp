@smoke
Feature: Processed online applications

  Background: Processed applications page
    Given I am signed in as a smoke user
    And there is an online application that has not been processed


  Scenario: Find and process the online application
    Given I an on the home page
    And I look up an online application
    Then I should see details of the smoke online application


