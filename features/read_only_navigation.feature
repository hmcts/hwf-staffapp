Feature: Read only navigation

   Background: Sign in as a read only user
     Given I successfully sign in read only user

    Scenario: View profile
      Then I can view my profile

    Scenario: Staff guides
      Then I can view staff guides

    Scenario: Feedback
      Then I can give feedback

    Scenario: Letter templates
      Then I can view letter templates
    
    Scenario: Sign out
      When I sign out
      Then I am taken to the sign in page

    Scenario: Unable to view office
      Then I should not be able to navigate to office details
  
    Scenario: Unable to edit banner
      Then I should not be able to navigate to edit banner
  
    Scenario: Unable to view staff
      Then I should not be able to navigate to the staff page
  
    Scenario: Unable to edit DWP message
      Then I should not be able to navigate to the DWP warning message page
