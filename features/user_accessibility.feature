@javascript @accessibility
Feature: Accessibility

  Background: Accessibility user pages
    Given I successfully sign in as a user

    Scenario: User dashboard page
      When I visit the dashboard page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: User online application
      Given An applicant has submitted an online application where fee has not been paid
      When I process the online application
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      And I click next
      Then I should be taken to the check details page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      And I complete processing
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa

    Scenario: User paper application
      When I start to process a new paper application
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      And I am on the personal details part of the application
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      And I successfully submit my required personal details
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      And I fill in the application details
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      When I successfully submit less than £4250
      Then I should be taken to the benefits page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      When I answer no to the benefits question
      Then I should be taken to the children page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      When I choose no chilren
      Then I should be taken to the incomes type page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      When I choose wages
      Then I should be taken to the incomes page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      When I submit the last month income
      Then I should be one the declaration page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      When I choose applicant and submit
      Then I am on the summary page
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
      When I complete processing
      And I take a screenshot of the page
      Then the page should be axe clean according to: wcag2aa
