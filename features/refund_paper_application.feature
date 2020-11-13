Feature: Refund on paper application

  Background: Application details page
    Given I have started an application
    And I am on the application details part of the application

  Scenario: Blank refund date
    When I submit a refund application with no refund date
    Then I should see a enter date in this format error

  Scenario: Valid refund date
    When I submit a refund application where refund date is within 3 months of application received date
    Then I should be taken to savings and investments page

  Scenario: Invalid refund date (too long ago)
    When I submit a refund application where refund date is beyond 3 months from application received date
    Then I should see a delivery manager discretion error

  Scenario: Invalid refund date (refund date is after the date that the form was received)
    When I submit a refund application where refund date is after the date that the form was received
    Then I should see an error message saying the refund date can't be later than receipt date

  Scenario: Yes delivery manager discretion - don't provide names
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select Yes to Delivery Manager discretion applied?
    And I submit without providing Delivery Manager name or Discretion reason
    Then I see two discretion related errors

  Scenario: Yes delivery manager discretion - provide names
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select Yes to Delivery Manager discretion applied?
    And I submit after providing Delivery Manager name or Discretion reason
    Then I should be taken to savings and investments page

  Scenario: Yes delivery manager discretion (Check details page)
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select Yes to Delivery Manager discretion applied?
    And I submit after providing Delivery Manager name or Discretion reason
    And I process application through to Check details page
    Then I should see Delivery Manager discretion applied Yes
    And I should see the date fee paid
    And I should see the Delivery Manager name
    And I should see the Discretionary reason

  Scenario: No delivery manager discretion
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select No to Delivery Manager discretion applied? and submit form
    Then I am on the Check details page
    And I should see Delivery Manager discretion applied No
    And I should see the date fee paid

  Scenario: No delivery manager discretion and then date changed (discretion question and form becomes hidden)
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select No to Delivery Manager discretion applied? and submit form
    And I click Change date fee paid on check details page
    And I change the date fee paid to a valid date
    Then I should not see Delivery Manager discretion applied? checkboxes

  Scenario: No delivery manager discretion and then date changed (check details page)
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select No to Delivery Manager discretion applied? and submit form
    And I click Change date fee paid on check details page
    And I change the date fee paid to a valid date and submit
    And I process application through to Check details page
    Then I should see the date fee paid
    And I should not see discretion information

  Scenario: No delivery manager discretion (Confirmation page)
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select No to Delivery Manager discretion applied? and submit form
    And I complete processing
    Then I am on the confirmation page
    And I see application is complete
    And I see that the applicant is not eligible for help with fees
    And I see Delivery Manager Discretion as Failed

  Scenario: No delivery manager discretion and then change to Yes delivery manager discretion
    When I submit a refund application where refund date is beyond 3 months from application received date
    And I select No to Delivery Manager discretion applied? and submit form
    And I click Change date fee paid on check details page
    And I select Yes to Delivery Manager discretion applied? and enter name and reason
    And I process application through to Check details page
    Then I should see Delivery Manager discretion applied Yes
    And I should see the date fee paid
    And I should see the Delivery Manager name
    And I should see the Discretionary reason
