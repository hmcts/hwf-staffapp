Feature: Unprocessed applications when DWP is down

  Scenario: Processing an online application when DWP Checker Service fails
    Given I am a staff member and I process an online benefit application
    When I add a jurisdiction
    And I click next
    Then I should be asked about paper evidence
    When I answer no and press Next
    Then I should be redirected to home page
    And I should see a message that the DWP Checker is not available
    And I should not see 'Process when DWP is back online' section

  Scenario: Processing a paper-based benefit application when DWP Checker Service fails
    Given I am a staff member and I process a paper-based benefit application
    And I'm on the 'Benefits the applicant is receiving page'
    And I answer 'Yes' to 'Is the applicant receiving one of these benefits?' question
    When  I press 'Next' and the DWP response is 'LSCBC959: Service unavailable'
    Then I should be redirected to home page
    And I should see a message that the DWP Checker is not available
    And I should see 'Process when DWP is back online' section
    And On selecting the link I should see the paper-based application I was just processing in a list

  Scenario: Complete processing of an application on the pending list after DWP checker is online by selecting 'Ready to process'
    Given There is an application pending
    And I am a staff member at the 'Pending benefit applications' page with the DWP checker online
    And there is an application in the pending list
    When I click on the application 'Ready to process' link
    And I complete processing the application
    Then I should be on the result page with the application status set to processed

  Scenario: Complete processing of an application on the pending list after DWP checker is online by selecting 'Id'
    Given There is an application pending
    And I am a staff member at the 'Pending benefit applications' page with the DWP checker online
    And there is an application in the pending list
    When I click on the application 'Id' link
    And I complete processing the application
    Then I should be on the result page with the application status set to processed

  Scenario: View an application on the pending list
    Given There is an application pending
    And I am a staff member at the home page
    And there is a heading 'Process when DWP is back online'
    And I see a link 'Pending applications to be processed' under the heading
    When I click on the 'Pending applications to be processed' link
    Then I should be on the page 'Pending benefit applications'
    And I should see subheading 'Process when DWP is back online'
    And I see a table view of pending applications
    And I should see all the pending application columns for non-admin

  Scenario: When there are no applications on the pending list
    Given There are no applications pending
    And I am a staff member at the home page
    Then There should be no heading 'Process when DWP is back online'

  Scenario: Should 'Not ready to process' an application on the pending list while DWP checker is offline
    Given There is an application pending
    And I am a staff member at the 'Pending benefit applications' page with the DWP checker offline
    And there is an application in the pending list
    Then I should see 'Not ready to process' in red text
    And the 'Id' should still be selectable as a link

  Scenario: The only applications visible on the list are within an office
    Given There are 2 applications that have been submitted and pending for different offices
    And I am a staff member at the 'Pending benefit applications' page with the DWP checker online
    Then I should only see the application for my office in the pending list

  Scenario: Logged in as an admin after DWP outage and can view pending application
    Given I am logged in as an admin and there is an application pending
    And there is a heading 'Process when DWP is back online'
    And I see a link 'Pending applications to be processed' under the heading
    When I click on the 'Pending applications to be processed' link
    Then I should be on the page 'Pending benefit applications'
    And I should see subheading 'Process when DWP is back online'
    And I see a table view of pending applications
    And I should see all the pending application columns for admin
    And I should see one application pending
