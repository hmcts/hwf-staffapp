Feature: Feedback received

Background: Feedback received page
  Given feedback has been left by a user
  And I successfully sign in as admin
  And I am on the feedback received page
  
Scenario: Feedback received
  Then I should see the feedback received
