Feature: My dashboard

  Background: Signed in as a user
    Given I successfully sign in as a user

  Scenario: In progress applications - waiting for evidence
    When I click on waiting for evidence
    Then I should be taken to evidence checks page

  Scenario: In progress applications - waiting for part-payment
    When I click on waiting for part-payment
    Then I should be taken to part payments page

  Scenario: View profile
    When I click on view profile
    Then I am taken to my details

  Scenario: Staff guides
    When I click on staff guides
    Then I am taken to the guide page

  Scenario: DWP connection
    Then I should see the status of the DWP connection

  @wip @manual
  Scenario: Search a valid reference
    When I search for an application using valid reference number
    Then I am taken to ....

  @wip @manual
  Scenario: Search an invalid reference
    When I search for an application using invalid reference number
    Then I should see the reference number is not recognised error message

  @wip @manual
  Scenario: Process a paper application
    When I start to process a new paper application
    Then I am taken to the applicants personal details page

  @wip @manual
  Scenario: Process an online application
    When I look up a valid hwf reference
    Then I am taken to ....

  @wip @manual
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
    Then I am taken to all processed applications

  Scenario: Deleted applications
    When I click on deleted applications
    Then I am taken to all deleted applicantions
  