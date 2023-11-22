Feature: Staff guides

  Background: Navigate to staff guides
    Given I am on the Help with Fees staff application home page

    Scenario: See the guides
      Then I can view guides by clicking on the link in the footer

    Scenario: Verify old Job Cards on staff app guides page
      Then I can view Staff guides link on footer
      When I click on Staff guides link
      Then I should be taken to the guide page
      And I will see old Job Cards link

    Scenario: Verify new Job Cards on staff app guides page
      Then I can view Staff guides link on footer
      When I click on Staff guides link
      Then I should be taken to the guide page
      And I will see new Job Cards link

    Scenario: Verify Job Cards as a signed-in user
      And I am signed in on the guide page
      Then I can view the old Job Cards

    Scenario: How to guide
      And I am signed in on the guide page
      Then I can view how to guide

    Scenario: Training course
      And I am signed in on the guide page
      Then I can view the training course

    Scenario: Key control checks
      And I am signed in on the guide page
      Then I can view key control checks guide

    Scenario: Old staff guidance
      And I am signed in on the guide page
      Then I can view old staff guidance

    Scenario: New staff guidance
      And I am signed in on the guide page
      Then I can view new staff guidance

    Scenario: Process application
      And I am signed in on the guide page
      When I click on process application
      Then I should be taken to the process application guide

    Scenario: Fraud awareness
      And I am signed in on the guide page
      Then I can view fraud awareness guide

    Scenario: Accessibility statement footer
      When I click on the accessibility link in the footer
      Then I am on the accessibility statement page
