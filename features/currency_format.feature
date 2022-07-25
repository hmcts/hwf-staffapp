Feature: Currency format

  Scenario: Letter - ineligible and no evidence check
    Given I successfully sign in as a user
    When I have completed an ineligible paper application - savings too high
    Then I should be on the paper application confirmation page
    And I should see amount to pay is an integer amount
    And I should see maximum amount of savings and investments allowed is an integer amount
    And I should see total savings is an integer amount

  Scenario: Letter - part payment and no evidence check
    Given I successfully sign in as a user
    When I have completed a part payment paper application
    Then I should be on the paper application confirmation page
    And I should see amount to pay is an integer amount
    And I should see total monthly income is an integer amount

  Scenario: Letter - eligible and waiting for evidence (evidence shows income is actually much higher)
    Given there is an eligible application waiting for evidence
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    And I submit that the evidence is correct
    And I submit 100000 as the income
    And I click next on the income result page
    When I click complete processing
    Then I should be on the evidence confirmation page
    And I should see amount to pay is an integer amount
    And I should see total monthly income is an integer amount

  Scenario: Letter - part payment and evidence check passed
    Given there is a part payment application waiting for evidence
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    And I submit that the evidence is correct
    And I submit 2200 as the income
    And I click next on the income result page
    When I click complete processing
    Then I should be on the evidence confirmation page
    And I should see amount to pay is an integer amount
    And I should see total monthly income is an integer amount

  Scenario: Letter - part refund and no evidence check
    Given I successfully sign in as a user
    When I have completed a part refund paper application
    Then I should be on the paper application confirmation page
    And I should see that all currency amounts are integers

  Scenario: Letter - part refund and evidence check passed
    Given there is a part refund application waiting for evidence
    And I am on an application waiting for evidence
    And I click on start now to process the evidence
    And I submit that the evidence is correct
    And I submit 2200 as the income
    And I click next on the income result page
    When I click complete processing
    Then I should be on the evidence confirmation page
    And I should see that all currency amounts are integers
