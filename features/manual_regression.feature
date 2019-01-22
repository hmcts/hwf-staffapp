@manual @wip

Feature: Manual regression tests

   Scenario: Invite user
     Given I am signed in as admin
     When I invite a new user
     Then that user can activate their account via a link on an email
     And they will be taken to the homepage

   Scenario: Invite manager
     Given I am logged in as admin
     When I invite a new manager
     Then that manager can activate their account via a link on an email
     And they will be taken to the change details page