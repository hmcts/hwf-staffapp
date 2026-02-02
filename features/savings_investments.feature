Feature: Savings and investments page

  Background: Savings and investments page
    Given I have started an application

    Scenario: Successfully submit less than £4250
      Given I am on the savings and investments part of the application
      When I successfully submit less than £4250
      Then I should be taken to the benefits page

    Scenario: Successfully submit between £4250 and £15999 under 66 years old
      Given I am on the savings and investments part of the application
      When I click between £4250 and £15999 under 66 years old
      And I enter £5000
      Then I should be taken to the benefits page

  Scenario: Successfully submit between £4250 and £15999 under 66 years old -  too much savings
    Given I am on the savings and investments part of the application
    When I click between £4250 and £15999 under 66 years old
    And I enter £15000
    Then My application gets no remission

  Scenario: Successfully submit between £4250 and £15999 over 66 years old
    Given I am on the savings and investments part of the application and over 66
    When I click between £4250 and £15999 over 66 years old
    Then I should be taken to the benefits page

  Scenario: Successfully submit between £4250 and £15999 over 66 years old - not 66 error
    Given I am on the savings and investments part of the application
    When I click between £4250 and £15999 over 66 years old
    Then I should see error message not 66

  Scenario: Successfully submit "£16000 or more"
    Given I am on the savings and investments part of the application
    When I click on more than £16000
    Then My application gets no remission

  Scenario: I press Next without selecting any radio button
    Given I am on the savings and investments part of the application
    When I click next without selecting a savings and investments option
    Then I should see a 'Please answer the savings question' error
