Feature: Evidence check will be called or not based off the NINO

  Background: Evidence check will be called or not based off the NINO
    Given UCD changes are active

  Scenario: One correct evidence check will pass all other checks
    Given I create an application A that waits for evidence
    And I create an Application B that has correct evidence
    When I create Application C
    And evidence check is skipped
    And I close application A
    Then I create Application D
    And evidence check is skipped

  Scenario: One evidence reject will mark subsequent applications
    Given I create an application A that waits for evidence
    And I create an Application B and wrong evidence is provided
    When I create Application C
    And evidence check is called
    When I create Application D
    And evidence check is called
    When Application C has correct evidence
    Then I create Application E
    And evidence check is skipped

  Scenario: One evidence reject after an evidence accept will mark subsequent applications
    Given I create an application A that waits for evidence
    And I create an Application B that has correct evidence
    When I create Application C
    And evidence check is skipped
    When Application A has failed evidence
    And I create Application D
    And evidence check is called
    When Application D has correct evidence
    Then I create Application E
    And evidence check is skipped


  Scenario: One correct evidence check will pass all other checks for same ho number
    Given I create an application A that waits for evidence with the same ho_number
    And I create an Application B that has correct evidence with the same ho_number
    When I create Application C with the same ho_number
    And evidence check is skipped
    And I close application A
    Then I create Application D with the same ho_number
    And evidence check is skipped

  Scenario: One evidence reject will mark subsequent applications for same ho number
    Given I create an application A that waits for evidence with the same ho_number
    And I create an Application B and wrong evidence is provided with the same ho_number
    When I create Application C with the same ho_number
    And evidence check is called
    When I create Application D with the same ho_number
    And evidence check is called
    When Application C has correct evidence
    Then I create Application E with the same ho_number
    And evidence check is skipped

  Scenario: One evidence reject after an evidence accept will mark subsequent applications for same ho number
    Given I create an application A that waits for evidence with the same ho_number
    And I create an Application B that has correct evidence with the same ho_number
    When I create Application C with the same ho_number
    And evidence check is skipped
    When Application A has failed evidence
    And I create Application D with the same ho_number
    And evidence check is called
    When Application D has correct evidence
    Then I create Application E with the same ho_number
    And evidence check is skipped

  Scenario: One evidence reject after an evidence accept will mark subsequent applications for same ho number but lowercase
    Given I create an application A that waits for evidence with the same ho_number
    And I create an Application B that has correct evidence with the same ho_number
    When I create Application C with the same ho_number and lowercase ho_number
    And evidence check is skipped
    When Application A has failed evidence
    And I create Application D with the same ho_number
    And evidence check is called
    When Application D has correct evidence
    Then I create Application E with the same ho_number
    And evidence check is skipped