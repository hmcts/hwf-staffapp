@manual @wip

Feature: Waiting for evidence
  Given I am on an application that is waiting for evidence

Scenario: Process evidence
  When I click on start now
  Then I should be taken to a page asking me if the evidence ready to process

Scenario: What to do if evidence cannot be processed
  When I click on what to do if the evidence cannot be processed
  Then I should see instructions with a button to return to application

Scenario: Personal details
  Then I should see the applicants personal details

Scenario: Application details
  Then I should see the applicantion details

Scenario: Applicants benefit details
  Then I should see the applicants benefit details

Scenario: Applicants income details
  Then I should see the applicants income details

Scenario: Result
  Then I should see whather the applicant is eligible for help with fees

Scenario: Processing summmary
  Then I should see the processing summmary
  