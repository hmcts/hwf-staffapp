Feature: DWP warning message

  Background: DWP warning message
    Given UCD changes are active

  Scenario: DWP message is displayed for users
    Given I successfully sign in as a user
    Then I should see a message saying I can process benefits and income based applications
  
  Scenario: Use default message is pre-selected
    Given I successfully sign in as admin
    And I am on the DWP warning message page
    Then I should see use the default DWP message is pre-selected

  Scenario: DWP is down message
    Given I successfully sign in as admin
    And I am on the DWP warning message page
    When I check display DWP check is down message
    And I click on save changes
    Then I should see your changes have been saved message
    When I go to the homepage by clicking on Help with fees
    Then I should see a message saying I am unable to check an applicants benefits
    
  Scenario: DWP is working message
    Given I successfully sign in as admin
    And I am on the DWP warning message page
    When I check display DWP check is working message
    And I click on save changes
    Then I should see your changes have been saved message
    When I go to the homepage by clicking on Help with fees
    Then I should see a message saying I can process benefits and income based applications
    
  Scenario: Use the default DWP message
    Given I successfully sign in as admin
    And I am on the DWP warning message page
    When I check use the default DWP check to display message
    And I click on save changes
    Then I should see your changes have been saved message
    When I go to the homepage by clicking on Help with fees
    Then I should see a message saying I can process benefits and income based applications
