Feature: Online application

  Scenario: Application details
    Given I have looked up an online application
    When I see the application details
    And I add a jurisdiction
    Then I should be taken to the check details page

  Scenario: Complete processing
    Given I have looked up an online application
    When I process the online application
    Then I see the applicant is not eligible for help with fees
    And back to start takes me to the homepage
    And I can see my processed application

  Scenario: Jurisdiction error message
    Given I have looked up an online application
    When I see the application details
    And I click next without selecting a jurisdiction
    Then I should see that I must select a jurisdiction error message
    
  