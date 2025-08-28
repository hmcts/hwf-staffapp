Feature: Processed applications

  Background: Processed applications page
    Given UCD changes are active
    Given I am signed in as a user that has processed multiple applications
    When I click on a processed application

    Scenario: Open an application
      Then I should be taken to that application

    Scenario: Displays benefit information
      Then I should see declared benefits in this processed application

    Scenario: Result
      When I look at the result on the processed application page
      Then I should see the result for savings on the processed application page
      And I should see the result for benefits on the processed application page

    Scenario: Delete a processed application (no reason)
      When I click the Delete application details element
      And I select a reason with a mandatory description
      And I click Delete application button without providing a reason
      Then I should see an Enter the reason error

    Scenario: Delete a processed application (with reason)
      When I click the Delete application details element
      And I click Delete application button after providing a reason
      Then I should be redirected to processed applications
      And I should see a message saying that the application has been deleted
