Feature: Waiting for evidence

  Background: Waiting for evidence
    Given there is an application waiting for evidence

  Scenario: Process evidence
    And I am on an application waiting for evidence
    When I click on start now to process the evidence
    Then I should be taken to a page asking me if the evidence ready to process

  Scenario: What to do if evidence cannot be processed
    And I am on an application waiting for evidence
    When I click on what to do if the evidence cannot be processed
    Then I should see instructions with a deadline to submit the evidence

  Scenario: Return application
   And I am on an application waiting for evidence
    When I click on return application
    Then I should be taken to the problem with evidence page

  Scenario: Applicants details
    And I am on an application waiting for evidence
    Then I should see the applicants personal details
    And I should see the application details
    And I should see the applicants benefit details
    And I should see the applicants income details
    And I should see the processing summmary

  Scenario: Evidence is correct
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    When I submit that the evidence is correct
    Then I should be taken to the evidence income page

  Scenario: Submit problem with evidence
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    When I submit that there is a problem with evidence
    Then I should be taken to the reason for rejecting the evidence page

  Scenario: Evidence error message
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    When I click on next without making a selection on the evidence page
    Then I should see this question must be answered error message

  Scenario: Full refund
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    And I submit that the evidence is correct
    When I submit 500 as the income
    Then I see the amount to be refunded should be £656.66

  Scenario: Not eligible income amount
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    And I submit that the evidence is correct
    When I submit 2950 as the income
    Then I see that the applicant is not eligible for help with fees

  Scenario: Partial refund
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    And I submit that the evidence is correct
    When I submit 2220 as the income
    Then I see the amount to be refunded should be £5

  Scenario: Check details
    And I am on an application waiting for evidence
    When I have successfully submitted the evidence
    Then I should see the evidence details on the summary page

  Scenario: Return to dashboard
    And I am on an application waiting for evidence
    When I have successfully submitted the evidence
    And I complete processing
    And I click on back to start
    Then I should be taken back to my dashboard
    And the application should have the status of processed

  Scenario: Verify back to list button
    And I am on an application waiting for evidence
    When I have successfully submitted the evidence
    And I complete processing
    And I click on back to list
    Then I am taken to the waiting for evidence page
