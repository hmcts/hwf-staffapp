Feature: Your feedback page

Background: Waiting for evidence
  Given I successfully sign in as a user
  And I am on your feedback page

Scenario: Urgent question
  Then I can email if I have an urgent question or something isn't working
  
Scenario: Your feedback
  When I successfully submit my feedback
  Then I should be taken to my dashboard
  And I should see your feedback has been recorded notification
