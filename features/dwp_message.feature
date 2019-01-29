@manual @wip

Feature: DWP warning message

  Background: Navigate to the DWP warning essage page
    Given I am on the DWP warning message page

    Scenario: DWP check is down message
      When I check display DWP check is down message
      And I click on save changes
      Then I should see your changes have been saved message
      And I should see the DWP check is currently unavailable warning message on my homepage
    
    Scenario: DWP check is working message
      When I check display DWP check is working message
      And I click on save changes
      Then I should see your changes have been saved message
      And I should see the DWP check is currently working message on my homepage
    
    Scenario: Use the default DWP check to display message when DWP is down
      And the DWP checker is working
      When I check use the default DWP check to display message
      And I click on save changes
      Then I should see your changes have been saved message
      And I should see the DWP check is currently working message on my homepage

    Scenario: Use the default DWP check to display message when DWP is working
      And the DWP checker is down
      When I check use the default DWP check to display message
      And I click on save changes
      Then I should see your changes have been saved message
      And I should see the DWP check is currently working message on my homepage
      