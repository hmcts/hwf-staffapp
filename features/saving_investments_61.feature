Feature: Savings and investment threshold on staff app

  Scenario: Applicant over 66 have different question after having £3000 or more in savings
    Given As a staff who is processing HwF paper application on the staff app,
    And The applicant is over 66 years old
    When I exceed saving limit
    Then I should see the question "In question 8, how much do they have?" with options "Less than £16,000" and "£16,000 or more"

  Scenario: Applicant under 66 have different question after having £3000 or more in savings
    Given As a staff who is processing HwF paper application on the staff app,
    And The applicant is under 66 years old
    When I exceed saving limit
    Then I should see the question "How much do they have in savings and investments?" and a text field
