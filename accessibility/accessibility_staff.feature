@javascript @accessibility
Feature: Accessibility of staff pages

  Scenario: Dashboard with applications in progress
    Given I am signed in as a user that has processed multiple applications
    When I visit the dashboard page
    Then I am taken to my user dashboard
    And the "Staff dashboard" page should meet accessibility standards

  Scenario: Processing a paper application - benefits, high fee, representative
    Given I successfully sign in as a user
    And the DWP benefit check will not respond
    When I start to process a new paper application
    Then I am on the fee status page
    And the "Date received and fee status" page should meet accessibility standards
    When I am on the personal details part of the application
    Then the "Personal details" page should meet accessibility standards
    When I submit my personal details with a National Insurance number
    Then I should be taken to the application details page
    And the "Application details" page should meet accessibility standards
    When I fill in the application details with a fee over the approval limit
    Then I should be taken to the ask a manager page
    And the "Ask a manager" page should meet accessibility standards
    When I successfully submit a manager name
    Then I should be taken to savings and investments page
    And the "Savings and investments" page should meet accessibility standards
    When I successfully submit less than £4250
    Then I should be taken to the benefits page
    And the "Benefits the applicant is receiving" page should meet accessibility standards
    When I answer yes to the benefits question
    Then I should be asked about paper evidence
    And the "Paper evidence of benefits" page should meet accessibility standards
    When I successfully submit my required paper evidence details
    Then I am on the declaration page
    And the "Declaration and statement of truth" page should meet accessibility standards
    When I sign the declaration as a legal representative
    Then I should be taken to the representative page
    And the "Representative details" page should meet accessibility standards
    When I submit the representative details
    Then I am on the summary page
    And the "Check details" page should meet accessibility standards
    When I complete processing
    Then I should be on the paper application confirmation page
    And the "Paper application confirmation" page should meet accessibility standards

  Scenario: Processing a paper application - income questions, married
    Given I successfully sign in as a user
    When I start to process a new paper application
    Then I am on the fee status page
    When I am on the personal details part of the application
    And I submit my personal details as a married applicant
    Then I should be taken to the partner details page
    And the "Partner details" page should meet accessibility standards
    When I submit the partner details
    Then I should be taken to the application details page
    When I fill in the application details
    Then I should be taken to savings and investments page
    When I successfully submit less than £4250
    Then I should be taken to the benefits page
    When I answer no to the benefits question
    Then I should be taken to the children page
    And the "Children" page should meet accessibility standards
    When I choose no chilren
    Then I should be taken to the incomes type page
    And the "Type of income" page should meet accessibility standards
    When I choose wages
    Then I should be taken to the partner income type page
    And the "Type of income the partner is receiving" page should meet accessibility standards
    When I choose wages for the partner
    Then I should be taken to the incomes page
    And the "Income" page should meet accessibility standards

  Scenario: Processing an online application
    Given I have looked up an online application with benefits
    When I see the application details
    Then the "Online application details" page should meet accessibility standards
    When I fill in missing online application details
    And I click next
    Then I should be taken to the check details page
    And the "Online application check details" page should meet accessibility standards

  Scenario: Result of a completed application
    Given I have looked up an online application with benefits
    When I process the online application with failed benefits
    Then I see the applicant is not eligible for help with fees
    And the "Online application result" page should meet accessibility standards

  Scenario: Checking the evidence for an application
    Given there is an application waiting for evidence
    And I am on an application waiting for evidence
    Then the "Application waiting for evidence" page should meet accessibility standards
    When I click on start now to process the evidence
    Then I should be taken to a page asking me if the evidence ready to process
    And the "Is the evidence ready to process" page should meet accessibility standards
    When I submit that the evidence is correct
    Then I should be taken to the evidence income page
    And the "Evidence income" page should meet accessibility standards
    When I submit 500 as the income
    Then I see the amount to be refunded should be £656.66
    And the "Evidence income result" page should meet accessibility standards
    When I continue from the evidence result page
    Then the "Evidence check details" page should meet accessibility standards
    When I complete processing
    Then I should be on the evidence confirmation page
    And the "Evidence confirmation" page should meet accessibility standards

  Scenario: Returning an application because of a problem with the evidence
    Given there is an application waiting for evidence
    And I am on an application waiting for evidence
    When I click on return application
    Then I should be taken to the problem with evidence page
    And the "What is the problem with the evidence" page should meet accessibility standards
    When I submit the page with not arrived or too late
    Then I should be taken to the return letter page
    And the "Evidence return letter" page should meet accessibility standards

   Scenario: Processing a part-payment
    Given I have processed an application that is a part payment
    When I go to the part payment application
    Then the "Application waiting for part-payment" page should meet accessibility standards
    When I start to process the part-payment
    Then the "Is the part-payment ready to process" page should meet accessibility standards
    When I confirm the part-payment is ready to process
    Then the "Part-payment check details" page should meet accessibility standards
    When I complete processing
    And I click on back to start
    And I open the processed part payment application
    Then I can see that the applicant has paid £40 towards the fee
    And the "Processed part-payment application" page should meet accessibility standards

  Scenario: Searching for an application
    Given I am signed in as a user that has processed multiple applications
    When I search for an application using a last name
    Then I should see a list of the results for that last name
    And the "Search results" page should meet accessibility standards

  Scenario: A processed application
    Given I am signed in as a user that has processed an application
    When I click on the reference number of one of my last applications
    Then  I am taken to the processed application
    And the "Processed applications list" page should meet accessibility standards

  Scenario: Deleted applications
    Given I successfully sign in as a user
    When I click on deleted applications
    Then I am taken to all deleted applications
    And the "Deleted applications list" page should meet accessibility standards

  Scenario: Applications waiting for evidence list
    Given I am signed in as a user that has processed an application that is waiting for evidence
    When I click on the waiting for evidence link
    Then I am taken to the waiting for evidence page
    And the "Waiting for evidence list" page should meet accessibility standards

  Scenario: Applications waiting for part-payment list
    Given I am signed in as a user that has processed an application that is a part payment
    When I click on the waiting for part payments link
    Then I am taken to the waiting for part payments page
    And the "Waiting for part-payments list" page should meet accessibility standards

  Scenario: Profile and details pages
    Given I successfully sign in as a user
    Then I can view my profile
    And the "Staff profile" page should meet accessibility standards
    Then I am on the change details page
    And the "Change your details page" page should meet accessibility standards

  Scenario: Leaving feedback
    Given I successfully sign in as a user
    And I am on your feedback page
    And the "Your feedback" page should meet accessibility standards