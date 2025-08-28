Feature: Datashare income checking

  Background: Signed in as a user
    Given UCD changes are active
    Given I successfully sign in as a user who has an online application that will be hmrc checked
    And I look up an online application using a valid reference number

  Scenario: Processing a full refund application
    Given I fill in the form details for a low income user
    When I press complete processing
    And I check the income for the correct month
    And There is no additional income for the user
    Then I should see application complete

  Scenario: Processing a partial refund application
    Given I fill in the form details for a medium income user
    When I press complete processing
    And I check the income for the correct month
    And There is no additional income for the user
    Then I should see waiting for part payment

  Scenario: Processing a no refund application
    Given I fill in the form details for a higher income user
    When I press complete processing
    And I check the income for the correct month
    And There is no additional income for the user
    Then I should see not eligible for help with fees

  Scenario: Processing an application with working tax credit
    Given I fill in the form details for an applicant with working tax credit
    When I press complete processing
    And I check the income for the correct month
    And There is no additional income for the user
    Then I should see the result for that application

  Scenario: Processing an application with recalculated entitlement date
    Given I fill in the form details for an applicant with recalculated tax credit
    When I press complete processing
    And I check the income for the correct month
    And There is an error message on income page
    Then I should see the result for that application
    And Evidence needs to be checked manualy

  Scenario: Processing an application with child tax credit
    Given I fill in the form details for an applicant with child tax credit
    When I press complete processing
    And I check the income for the correct month
    And There is no additional income for the user
    Then I should see the result for that application

