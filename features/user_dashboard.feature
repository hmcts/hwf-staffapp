Feature: User dashboard

  Background: Signed in as a user
    Given I successfully sign in as a user

  Scenario: View profile
    When I click on view profile
    Then I am taken to my details
  
  Scenario: Staff guides
    When I click on staff guides
    Then I am taken to the guide page

  Scenario: Feedback
    When I click on Tell us what you think
    Then I am taken to the feedback page

  Scenario: Letter templates
    When I click on Letter templates
    Then I am taken to the Letter templates

  Scenario: Process application
    When I start to process a new paper application
    Then I am taken to the applicants personal details page

  Scenario: Unable to view office
    Then I should not be able to navigate to office details

  Scenario: Unable to edit banner
    Then I should not be able to navigate to edit banner

  Scenario: Unable to view staff
    Then I should not be able to navigate to the staff page

  Scenario: Unable to edit DWP message
    Then I should not be able to navigate to the DWP warning message page

  Scenario: Sign out
    When I sign out
    Then I am taken to the sign in page

    @wip @manual
  Scenario: Process an online application
    When I look up a valid hwf reference
    Then I am taken to ....

    @wip @manual
  Scenario: Invalid hwf number
    When I look up a invalid hwf reference
    Then I should see the reference number is not recognised error message

    @wip @manual
  Scenario: Waiting for evidence
    When I click on the reference number of an application that is waiting for evidence
    Then I am taken to the application waiting for evidence

    @wip @manual
  Scenario: Waiting for part-payment
    When I click on the reference number of an application that is waiting for part-payment
    Then I am taken to the application waiting for part-payment

    @wip @manual
  Scenario: Your last applications
    When I click on the reference number of one of my last applications
    Then I am taken to that application

    @wip @manual
  Scenario: Processed applications
    When I click on processed applications
    Then I am taken to all processed applications

    @wip @manual
  Scenario: Deleted applications
    When I click on deleted applications
    Then I am taken to all deleted applications
