Feature: Skip evidence check for 15 and under

  Scenario: If the applicant is under 15, '15 and under' is displayed on the Summary page
    Given I am a staff member with CCMCC office and I process a paper-based income application
    And I enter the date of birth of the applicant as under 15 years old
    When I get to the 'Summary page'
    Then I should see a row '15 and under' under the date of birth

  Scenario: If the applicant is 15, '15 and under' is displayed on the Summary page
    Given I am a staff member with CCMCC office and I process a paper-based income application
    And I enter the date of birth of the applicant as 15 years old
    When I get to the 'Summary page'
    Then I should see a row '15 and under' under the date of birth

  Scenario: If the applicant is over 15, '15 and under' is not displayed on the Summary page
    Given I am a staff member with CCMCC office and I process a paper-based income application
    And I enter the date of birth of the applicant as over 15 years old
    When I get to the 'Summary page'
    Then I should not see a row '15 and under' under the date of birth

  Scenario: If the applicant is under 15 skip the evidence check
    Given I am a staff member with CCMCC office and I process a paper-based income application
    And I enter the date of birth of the applicant as under 15 years old
    And when I get to the 'Summary page'
    When the application is completed
    Then the application will skip the evidence check

  Scenario: If the applicant is 15 skip the evidence check
    Given I am a staff member with CCMCC office and I process a paper-based income application
    And I enter the date of birth of the applicant as 15 years old
    And when I get to the 'Summary page'
    When the application is completed
    Then the application will skip the evidence check

  Scenario: If the applicant is over 15 then do not skip the evidence check
    Given I am a staff member with CCMCC office and I process a paper-based income application
    And I enter the date of birth of the applicant as over 15 years old
    And when I get to the 'Summary page'
    When the application is completed
    Then the application will not skip the evidence check
