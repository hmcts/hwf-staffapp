Feature: Confirmation page

  Background: Confirmation page
    Given I have processed an application
    And I am on the confirmation page

    Scenario: Result
      When I look at the result
      Then I should see the result for savings and investments
      And I should see the result for benefits

    Scenario: Eligibility
      Then I should see that the applicant is eligible for help with fees
    
    Scenario: Reference number
      Then I should see a help with fees reference number

    Scenario: Next steps
      Then I should see the next steps

    Scenario: See the guides
      Then I can view the guides in a new window

    Scenario: Back to start
      When I click on back to start
      Then I should be taken back to my dashboard
      And I should see my processed application in your last applications
