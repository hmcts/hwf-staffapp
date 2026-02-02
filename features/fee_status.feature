Feature: Fee status page

  Background: Personal details page
    Given I started to process paper application
    And I am on the fee status page

    Scenario: Required information
      When I click on next without answering any questions
      Then I should see that I must fill in date received
      And I should have to enter refund information

    Scenario: Refund outside date range
      When I fill in date received
      And I will in refund with range outside of the scope
      Then I should see error about the refund date
      When I fill in discretion
      Then I should be on personal page

    Scenario: Updated application detail page
      When I fill in date received
      And I will in refund within range
      Then I should be on personal page
      And new legislation applies
      When I successfully submit my required personal details
      Then I should be taken to the application details page
      And I should not see fields from fee status page
      When I successfully submit my required application details post UCD
      Then I should be taken to savings and investments page
      When I successfully submit less than £4250
      Then I should be taken to the benefits page
      When I answer no to the benefits question
      Then I should be taken to the children page
      When I choose no chilren
      Then I should be taken to the incomes type page
      When I choose wages
      Then I should be taken to the incomes page
      And I submit the last month income
      Then I should be one the declaration page
      When I choose applicant and submit
      Then I am on the summary page
      And I should see a fee status section
      When I click on change date received link
      Then I am on the fee status page




