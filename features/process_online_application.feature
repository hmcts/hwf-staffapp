Feature: Process an online application

  Background: Looking up an online application
    Given UCD changes are active
    Given I have looked up an online application with benefits

  Scenario: Application details
    When I see the application details
    When I fill in missing online application details
    And I click next
    Then I should be taken to the check details page

  Scenario: Complete processing
    And I process the online application with failed benefits
    Then I see the applicant is not eligible for help with fees
    And back to start takes me to the homepage
    And I can see my processed application

  Scenario: Jurisdiction error message
    When I see the application details
    And I click next without selecting a jurisdiction
    Then I should see that I must select a jurisdiction error message

  Scenario: Before you start and emergency content presence validation
    Then I should see digital before you start advice
    And I see that I should see digital check that the applicant is not
    And I see digital check the fee
    And I see digital Emergency advice
    And I see digital examples of emergency cases

  Scenario: Select emergency but don't enter a reason
    When I see the application details
    And I add a jurisdiction
    And I click emergency checkbox
    And I click next without entering a reason
    Then I should see a must enter an emergency reason error message

  Scenario: Select emergency and enter a reason
    When I see the application details
    And I fill in missing online application details
    And Benefit Check is ok
    And I click emergency checkbox
    And I click next after entering a reason
    Then I should be taken to the check details page
