Feature: Staff guides

  Background: Navigate to staff guides
    Given I am on the Help with Fees staff application home page

    Scenario: See the guides
      When I click on see the guides in the footer
      Then I should be taken to the guide page
      And I should not see you need to sign in error message
    
    @wip
    Scenario: How to guide
      Then I should be able to view the how to guide PDF

    @wip
    Scenario: Key control checks
      Then I should be able to view the key control checks PDF

    @wip
    Scenario: Staff guidance
      Then I should be able to view the staff guidance PDF
    
    @wip
    Scenario: Process application
      Then I should be taken to process application guide page

    @wip
    Scenario: Evidance checks
      Then I should be taken to evidance checks guide

    @wip
    Scenario: Part-payments
      Then I should be taken to part-payments guide
    
    @wip
    Scenario: Appeals
      Then I should be taken to appeals guide
    
    @wip
    Scenario: Fraud awareness
      Then I should be able to view the fraud awareness

    @wip
    Scenario: Suspected fraud
      Then I should be taken to suspected fraud guide
      