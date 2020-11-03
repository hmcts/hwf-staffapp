Feature: Savings and investments page

  Background: Savings and investments page
    Given I have started an application
    And I am on the savings and investments part of the application

    Scenario: Successfully submit less than £3000
      When I successfully submit less than £3000
      Then I should be taken to the benefits page

    Scenario: Successfully submit more than £3000
      When I click on more than £3000
      And I submit how much they have
      Then I should be taken to the summary page

    Scenario: I press Next without selecting either radio button
      When I click next without selecting a savings and investments option
      Then I should see a 'Please answer the savings question' error

    Scenario: I select "£3000 or more" but don't submit a value in the textbox
        When I click on more than £3000
        And I don't submit how much they have
        Then I should see a 'Please enter the amount of savings and investments' error

    Scenario: I select "£3000 or more" but submit a non-numerical input in the textbox
      When I click on more than £3000
      And I submit a non-numerical input
      Then I should see a 'The value that you entered is not a number' error

    Scenario: I select "£3000 or more" but submit a number less than £3000
      When I click on more than £3000
      And I submit a value less than £3000
      Then I should see a 'must be greater than or equal to 3000' error
