Feature: Override results Discretionary pass

  Background: Signed in as user and halfway through processing paper application
    Given UCD changes are active
    Given I successfully sign in as a user
    And I process a paper application to the saving and investments page

  Scenario: High savings - before granting hwf
    When I submit a high savings amount and complete processing
    Then I should see a confirmation letter
    And I should see that the application fails because of saving and investments

  Scenario: High income - before granting hwf
    When I input low savings and no benefits but 5000 income and then complete processing
    Then I should see a confirmation letter
    And I should see that the application fails because of income

  Scenario: High income - after granting hwf
    Given I input low savings and no benefits but 5000 income and then complete processing
    When I grant help with fees by choosing delivery manager discretion
    Then I should see the applicant has been granted help with fees
    And The results should show the application passed income by manager's discretion
    And I should not see a confirmation letter

  Scenario: Benefits no paper evidence - before granting hwf
    When I input low savings with benefits but no paper evidence and then complete processing
    Then I should see a confirmation letter
    And I should see that the application fails because of benefits

  # Disabled for now
  # Scenario: Benefits no paper evidence - after granting hwf
  #   Given I input low savings with benefits but no paper evidence and then complete processing
  #   When I grant help with fees by choosing delivery manager discretion
  #   Then I should see the applicant has been granted help with fees
  #   And The results should show the application passed benefits by manager's discretion
  #   And I should not see a confirmation letter
