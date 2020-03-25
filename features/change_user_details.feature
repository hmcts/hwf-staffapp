Feature: Change user details

  Scenario: Role permission for manager
    Given I am manager on the staff page
    When I click on change details of a user
    Then I can not change the users role
  
  Scenario: Role permission for admin
    Given I am admin on the staff page
    When I click on change details of a user
    Then I can change the user to a user, manager, admin, mi, reader

  Scenario: User profile is saved
    Given I am admin on the staff page
    When I click on change details of a user
    And I change the member of staff to a reader
    Then I can see that the user is a reader

  Scenario: Main jurisdiction
    Given I am admin on the staff page
    When I click on change details of a user
    And I change the jurisdiction
    Then I should see the jurisdiction has been updated
