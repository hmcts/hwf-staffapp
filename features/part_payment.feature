Feature: Processing part payments

  Background: Processed refund application that requires a part payment
    Given I have processed an application that is a part payment

  Scenario: Successfully process part payment
    And the payment is ready to process
    When I complete processing
    And I click on back to start
    And I open the processed part payment application
    Then I can see that the applicant has paid £40 towards the fee

  Scenario: Part payment is not ready to process
    When the payment is not ready to process
    Then I should see my reason on the part payments summary page
    And I can see that the applicant needs to make a new application
    When processing is complete I should see a letter template

  Scenario: Part payment has not been received
    When I go to the part payment application
    And I click on What to do when a part payment has not been received
    And I click Return application
    Then I should see a Processing complete banner
    And I should see a letter template for no received part-payment
    And I should see a Back to start button
