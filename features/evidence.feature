Feature: Waiting for evidence

Background: Waiting for evidence
  Given I successfully sign in as a user
  And I am on an application waiting for evidence
  
Scenario: Process evidence
  When I click on start now
  Then I should be taken to a page asking me if the evidence ready to process

Scenario: What to do if evidence cannot be processed
  When I click on what to do if the evidence cannot be processed
  Then I should see instructions with a deadline to submit the evidence

Scenario: Return application
  When I click on return application
  Then I should be taken to the return letter page
  And I should see a return application letter template

Scenario: Return application
  When I click on return application
  And when I click on finish
  Then I should be taken back to my dashboard

Scenario: Applicants personal details
  Then I should see the applicants personal details

Scenario: Applicants application details
  Then I should see the application details

Scenario: Applicants benefit details
  Then I should see the applicants benefit details

Scenario: Applicants income details
  Then I should see the applicants income details

Scenario: Result
  Then I should see whather the applicant is eligible for help with fees

Scenario: Processing summmary
  Then I should see the processing summmary

Scenario: Evidence is correct
  And I click on start now
  When I submit that the evidence is correct
  Then I should be taken to the evidence income page

Scenario: Submit problem with evidence
  And I click on start now
  When I submit that there is a problem with evidence
  Then I should be taken to the problem with the evidence page

Scenario: Problem with evidence error message
  And I click on start now
  When I do not give a reason
  Then I should see this question must be answered error message

Scenario: Eligible income amount
  And I click on start now
  And I submit that the evidence is correct
  When I submit 500 as the income
  Then I see that the applicant is eligible for help with fees

Scenario: Not eligible income amount
  And I click on start now
  And I submit that the evidence is correct
  When I submit 2300 as the income
  Then I see that the applicant is not eligible for help with fees

Scenario: Part payment income amount
  And I click on start now
  And I submit that the evidence is correct
  When I submit 1500 as the income
  Then I see that the applicant needs to make a payment towards the fee

Scenario: Check details
  When I have successfully submitted the evidence
  Then I should see the evidence details on the summary page

Scenario: Return to dashboard
  When I have successfully submitted the evidence
  And I complete processing
  Then I should be taken back to my dashboard
