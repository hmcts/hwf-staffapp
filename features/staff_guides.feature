Feature: Staff guides

  Background: Navigate to staff guides
    Given I am on the Help with Fees staff application home page

    Scenario: See the guides
      Then I can view guides by clicking on the link in the footer

  Scenario: Verify How to Guide on staff app guides page
    Then I can view Staff guides link on footer
    When I click on Staff guides link
    Then I should be taken to the guide page
    And I can view How to Guide

    Scenario: How to guide
      And I am signed in on the guide page
      Then I can view How to Guide

    Scenario: Training course
      And I am signed in on the guide page
      Then I can view the training course

    Scenario: Key control checks
      And I am signed in on the guide page
      Then I can view key control checks guide

    Scenario: Staff guidance
      And I am signed in on the guide page
      Then I can view staff guidance

    Scenario: Old Process application
      And I am signed in on the guide page
      Then I can view old process application

    Scenario: New Process application
      And I am signed in on the guide page
      Then I can view new process application

    Scenario: New Online Process application
      And I am signed in on the guide page
      Then I can view new online process application

    Scenario: Old Evidence Checks
      And I am signed in on the guide page
      Then I can view old evidence checks

    Scenario: New Evidence Checks
      And I am signed in on the guide page
      Then I can view new evidence checks

    Scenario: Part Payment
      And I am signed in on the guide page
      Then I can view part payments

    Scenario: Fraud awareness
      And I am signed in on the guide page
      Then I can view fraud awareness guide

    Scenario: RRDS
      And I am signed in on the guide page
      Then I can view RRDS

    Scenario: HMRC Datashare
      And I am signed in on the guide page
      Then I can view HMRC Datashare

    Scenario: Accessibility statement footer
      When I click on the accessibility link in the footer
      Then I am on the accessibility statement page
