Feature: Benefit checker

  Background: Benefit checker
    Given UCD changes are active

  Scenario: Income based or paper evidence notification
    Given I am signed in as a user and I see the benefit checker is down
    Then I should see a notification telling me that I can only process income-based applications or where the applicant has provided paper evidence

  Scenario: Paper evidence for an applicant receiving benefits
    Given I am signed in as a user and I see the benefit checker is down
    When I start processing a paper application with no benefits record
    And I am on the benefits paper evidence page
    Then I should see that I will need paper evidence for the benefits

  Scenario: The applicant has not provided the correct paper evidence
    Given I am signed in as a user and I see the benefit checker is down
    When I start processing a paper application with no benefits record
    And I am on the benefits paper evidence page
    And the applicant has not provided the correct paper evidence
    Then I should see that the applicant fails on benefits

  Scenario: The applicant has provided the correct paper evidence
    Given I am signed in as a user and I see the benefit checker is down
    When I start processing a paper application with no benefits record
    And I am on the benefits paper evidence page
    And the applicant has provided the correct paper evidence
    Then I should see that the applicant passes on benefits

  Scenario: The applicant has provided the correct paper evidence for online application
    Given I have looked up an online application when the benefit checker is down
    Then I processed the applications until benefit paper evidence page
    And the applicant has provided the correct paper evidence without declaration
    Then I should see that the applicant passes on benefits

  Scenario: Benefit checker is now back online
    Given the benefit checker is down
    When an admin changes the DWP message to display DWP check is working message
    Then benefits and income based applications can be processed

  Scenario: DWP is down message is displayed when logged out
    Given I am not logged in and the benefit checker down
    Then I should see DWP checker is down

  Scenario: DWP is up message is displayed when logged out
    Given I am not logged in and the benefit checker up
    Then I should see DWP checker is up
