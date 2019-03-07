@manual @wip

Feature: My dashboard

  Background: Signed in as a user
    Given I successfully sign in as a user

  Scenario: View profile
    When I click on view profile
    Then I am taken to my details
  
  Scenario: Staff guides
    When I click on staff guides
    Then I am taken to the guide page

  Scenario: Process application
    When I start a new application
    Then I am taken to the applicants personal details page

  Scenario: Process an online application
    When I look up a valid hwf reference
    Then I am taken to ....

  Scenario: Invalid hwf number
    When I look up a invalid hwf reference
    Then I should see the reference number is not recognised error message

  Scenario: Waiting for evidence
    When I click on the reference number of an application that is waiting for evidence
    Then I am taken to the application waiting for evidence

  Scenario: Waiting for part-payment
    When I click on the reference number of an application that is waiting for part-payment
    Then I am taken to the application waiting for part-payment

  Scenario: Your last applications
    When I click on the reference number of one of my last applications
    Then I am taken to that application
    
  Scenario: Processed applications
    When I click on processed applications
    Then I am taken to all processed applicantions
  
  Scenario: Deleted applications
    When I click on deleted applications
    Then I am taken to all deleted applicantions
  