Feature: Summary page

  Scenario: Successfully submit my application
      Given I have completed an application
      And I am on the summary page
      When I successfully submit my application
      Then I should be taken to the confirmation page

    Scenario: Displays personal details
      Given I have completed an application
      And I am on the summary page
      Then I should see the personal details

    Scenario: Change personal details
      Given I have completed an application
      And I am on the summary page
      Then I should see the personal details
      When I click on change Date of Birth
      Then I am on the personal details page
      And I change the personal data
      Then I should see that my new answer is displayed in the personal details summary

    Scenario: Change application details
      Given I have completed an application
      And I am on the summary page
      Then I should see the application details
      When I click on change date received
      Then I am on the application details page
      And I change the application data
      Then I should see that my new answer is displayed in the application details summary

    Scenario: Displays benefit summary with paper override
      Given I have completed an application with paper evidence benefit check
      And I am on the summary page
      When I see benefit summary
      Then I should see declared benefits in this application
      And I should not see income details section
      And I have provided the correct evidence

    Scenario: Change benefit answers
      Given I have completed an application
      And I am on the summary page
      When I click on change benefits
      And I change my answer to no
      Then I should see that my new answer is displayed in the benefit summary
      And I should see income details section

    Scenario: Savings amount is rounded to the nearest pound
      When I have completed an application with savings in pence
      Then I should see that the savings amount is rounded to the nearest pound
