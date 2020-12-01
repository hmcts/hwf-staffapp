Feature: Summary page

  @smoke
    Scenario: Successfully submit my application
      Given I have completed an application
      And I am on the summary page
      When I successfully submit my application
      Then I should be taken to the confirmation page

    Scenario: Displays personal details
      Given I have completed an application
      And I am on the summary page
      Then I should see the personal details

    Scenario: Displays benefit summary
      Given I have completed an application
      And I am on the summary page
      When I see benefit summary 
      Then I should see declared benefits in this application
      And I have provided the correct evidence

    Scenario: Change benefit answers
      Given I have completed an application
      And I am on the summary page
      When I click on change benefits
      And I change my answer to no
      Then I should see that my new answer is displayed in the benefit summary

    Scenario: Savings amount is rounded to the nearest pound
      When I have completed an application with savings in pence
      Then I should see that the savings amount is rounded to the nearest pound
