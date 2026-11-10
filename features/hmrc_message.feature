Feature: HMRC warning message

  Scenario: Use default message is pre-selected
    Given I successfully sign in as admin
    And I am on the HMRC warning message page
    Then I should see use the default HMRC message is pre-selected

  Scenario: HMRC is down message
    Given I successfully sign in as admin
    And I am on the HMRC warning message page
    When I check display HMRC check is down message
    And I click on save changes
    Then I should see your changes have been saved message
    When I go to the homepage by clicking on Help with fees
    Then I should see a message saying there are problems with the HMRC checker

  Scenario: HMRC is working message
    Given I successfully sign in as admin
    And I am on the HMRC warning message page
    When I check display HMRC check is working message
    And I click on save changes
    Then I should see your changes have been saved message
    When I go to the homepage by clicking on Help with fees
    Then I should see a message saying the HMRC checker is working

  Scenario: Use the default HMRC message
    Given I successfully sign in as admin
    And I am on the HMRC warning message page
    When I check use the default HMRC check to display message
    And I click on save changes
    Then I should see your changes have been saved message
    When I go to the homepage by clicking on Help with fees
    Then I should see a message saying the HMRC checker is working
