Feature: Benefit checker

   Background: Benefit checker is down
     Given I am signed in as a user and I see the benefit checker is down

   Scenario: Paper application notification
     Then I should see a notification telling me that I can only process income-based applications
     And applications where the applicant has provided paper evidence

