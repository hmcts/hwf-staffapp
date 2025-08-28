Feature: User dashboard and navigation

  Background: User dashboard and navigation
    Given UCD changes are active

  Scenario: View profile
    Given I successfully sign in as a user
    When I click on view profile
    Then I am taken to my details

  Scenario: Staff guides
    Given I successfully sign in as a user
    When I click on staff guides
    Then I am taken to the staff guides page

  Scenario: Feedback
    Given I successfully sign in as a user
    When I click on feedback
    Then I am taken to the feedback page

  Scenario: Old letter templates
    Given I successfully sign in as a user
    When I click on letter templates
    Then I am taken to the letter templates page

  Scenario: New letter templates
    Given I successfully sign in as a user
    When I click on new letter templates
    Then I am taken to the new letter templates page

  Scenario: Sign out
    Given I successfully sign in as a user
    When I click on sign out
    Then I am taken to the sign in page

  Scenario: Unable to view office
    Given I successfully sign in as a user
    Then I should not be able to navigate to office details

  Scenario: Unable to edit banner
    Given I successfully sign in as a user
    Then I should not be able to navigate to edit banner

  Scenario: Unable to view staff
    Given I successfully sign in as a user
    Then I should not be able to navigate to the staff page

  Scenario: Unable to edit DWP message
    Given I successfully sign in as a user
    Then I should not be able to navigate to the DWP warning message page

  Scenario: DWP connection
    Given I successfully sign in as a user
    Then I should see the status of the DWP connection

  Scenario: Process a paper application
    Given I successfully sign in as a user
    When I start to process a new paper application
    Then I am on the personal details part of the application

  Scenario: Process an online application using a valid reference number
    Given I successfully sign in as a user who has an online application reference number
    When I look up an online application using a valid reference number
    Then I see the application details

  Scenario: Process an online application using an invalid reference number
    Given I successfully sign in as a user who has an online application reference number
    When I look up an online application using an invalid reference number
    Then I see an error message saying the reference number is not recognised

  Scenario: Search a valid reference
    Given I am signed in as a user that has processed an application
    When I search for an application using a valid hwf reference
    Then I see that application under search results

  Scenario: Search an invalid reference
    Given I am signed in as a user that has processed an application
    When I search for an application using an invalid hwf reference
    Then I see an error message saying no results found

  Scenario: Your last applications (Processed application)
    Given I am signed in as a user that has processed an application
    When I click on the reference number of one of my last applications
    Then I am taken to the processed application

  Scenario: Your last applications (Waiting for evidence application)
    Given I am signed in as a user that has processed an application that is waiting for evidence
    When I click on the reference number of one of my last applications
    Then I am taken to the application waiting for evidence

  Scenario: Your last applications (Waiting for part-payment)
    Given I am signed in as a user that has processed an application that is a part payment
    When I click on the reference number of one of my last applications
    Then I am taken to the application waiting for part-payment

  Scenario: Your last applications (Waiting for hmrc evidence application)
    Given I am signed in as a user that has processed an application that is a waiting for hmrc evidence
    When I click on the reference number of one of my last applications
    Then I am taken to the hmrc check page

  Scenario: Waiting for evidence page with hmrc check application
    Given I am signed in as a user that has processed an application that is a waiting for hmrc evidence
    When I click on the evidence check list link
    Then I am taken to the hmrc check page

  Scenario: Waiting for evidence page
    Given I successfully sign in as a user
    When I click on the waiting for evidence link
    Then I am taken to the waiting for evidence page

  Scenario: Waiting for part payments page
    Given I successfully sign in as a user
    When I click on the waiting for part payments link
    Then I am taken to the waiting for part payments page

  Scenario: Processed applications
    Given I successfully sign in as a user
    When I click on processed applications
    Then I am taken to all processed applications

  Scenario: Deleted applications
    Given I successfully sign in as a user
    When I click on deleted applications
    Then I am taken to all deleted applications
