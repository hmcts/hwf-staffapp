Feature: Staff guides

  Background: Navigate to staff guides
    Given I am on the Help with Fees staff application home page

    Scenario: See the guides
      Then I can view guides by clicking on the link in the footer

  Scenario: Verify Job Cards on staff app guides page
    Then I can view Staff guides link on footer
    When I click on Staff guides link
    Then I should be taken to the guide page
    And I will see a Job Cards link

    Scenario: Verify Job Cards as a signed-in user
      And I am signed in on the guide page
      Then I can view the Job Cards

    Scenario: How to guide
      And I am signed in on the guide page
      Then I can view how to guide

    Scenario: Training course
      And I am signed in on the guide page
      Then I can view the training course

    Scenario: Key control checks
      And I am signed in on the guide page
      Then I can view key control checks guide

    Scenario: Staff guidance
      And I am signed in on the guide page
      Then I can view staff guidance

    Scenario: Process application
      And I am signed in on the guide page
      When I click on process application
      Then I should be taken to the process application guide

    Scenario: Evidence checks
      And I am signed in on the guide page
      When I click on evidence checks
      Then I should be taken to the evidence checks guide

    Scenario: Part-payments
      And I am signed in on the guide page
      When I click on part-payments
      Then I should be taken to the part-payments guide

    Scenario: Appeals
      And I am signed in on the guide page
      When I click on appeals
      Then I should be taken to the appeals guide

    Scenario: Fraud awareness
      And I am signed in on the guide page
      Then I can view fraud awareness guide

    Scenario: Suspected fraud
      And I am signed in on the guide page
      When I click on suspected fraud
      Then I should be taken to the suspected fraud guide

    Scenario: Accessibility statement footer
      When I click on the accessibility link in the footer
      Then I am on the accessibility statement page
