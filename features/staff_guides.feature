@manual

Feature: Staff guides

  Background: Navigate to staff guides
    Given I am on the staff guides page

    Scenario: How to guide
      Then I should be able to view the how to guide PDF

    Scenario: Key control checks
      Then I should be able to view the key control checks PDF

    Scenario: Staff guidance
      Then I should be able to view the staff guidance PDF
    
    Scenario: Process application
      Then I should be taken to process application guide page

    Scenario: Evidance checks
      Then I should be taken to evidance checks guide

    Scenario: Part-payments
      Then I should be taken to part-payments guide
    
    Scenario: Appeals
      Then I should be taken to appeals guide
    
    Scenario: Fraud awareness
      Then I should be able to view the fraud awareness

    Scenario: Suspected fraud
      Then I should be taken to suspected fraud guide
      