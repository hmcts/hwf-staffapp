Feature: Benefit checker

  Background: Benefit checker is down
    Given I am signed in as a user and I see the benefit checker is down

  Scenario: Income based or paper evidence notification
    Then I should see a notification telling me that I can only process income-based applications or where the applicant has provided paper evidence

  Scenario: Paper evidence for an applicant receiving benefits
    When I start processing a paper application
    And I am on the benefits paper evidence page
    Then I should see that I will need paper evidence for the benefits

  Scenario: The applicant has not provided the correct paper evidence
    When I start processing a paper application
    And I am on the benefits paper evidence page
    And the applicant has not provided the correct paper evidence
    Then I should see that the applicant fails on benefits

  Scenario: The applicant has provided the correct paper evidence
    When I start processing a paper application
    And I am on the benefits paper evidence page
    And the applicant has provided the correct paper evidence
    Then I should see that the applicant passes on benefits
