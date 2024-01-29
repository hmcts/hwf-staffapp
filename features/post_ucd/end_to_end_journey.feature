Feature: End to end journey

  Background: Home page
    Given I have started a paper application
    And I am on the fee status page

    Scenario: Non refund income aplication single no children
      When I fill in date fee received to today
      And I choose no to a fee paid and press Next
      Then I am on the personal details page

      When I fill in name and date of birth of single applicant and submit
      Then I am on the application details page

      When I fill in 100 fee and jurisdiction
      And I fill in form number and press Next
      Then I am on the savings and investments page
      When I choose less then option and press Next
      Then I am on the benefits the applicant is receiving page

      When I choose no to receiving benefits question and press Next
      Then I am on the children page

      When I choose no to do you support any children question and press Next
      Then I am on the type of income the applicant is receiving page

      When I select wages and universal credit and press Next
      Then I am on the income page

      When I fill in 1500 for income
      And I choose last calendar month and press Next
      Then I am on the declaration and statement of truth page

      When I choose Applicant and press Next
      Then I am on the check details page

      And I should see today date received date
      And I should see no refund
      And I should see Full name
      And I should see dob
      And I should see single status
      And I should see Fee 100
      And I should see correct jurisdiction
      And I should see Form number
      And I should see Less than £4,250 to be Yes
      And I should see Between £4,250 and £15,999 to be No
      And I should see More than £16,000 to be No
      And I should see Benefits to be No
      And I should see Children to be No
      And I should see Income with value 1500
      And I should see Income period to be last calendar month
      And I should see Income period to be last calendar month
      And I should see Applicant income type to be wages and universal credit
      And I should see Declaration statement to be applicant

      When I press Complete processing
      Then I should see "The applicant must pay £40 towards the fee" text
      And I should see that savings passed
      And I should see that income is part payment
      And I should see that new HwF scheme applies

      When I click Back to start
      Then I should see that my last application has waiting_for_part_payment status
      When I click on the reference number
      Then I am on the waiting for part-payment page

      And I should see today date received date
      And I should see no refund
      And I should see Full name
      And I should see dob
      And I should see single status
      And I should see Fee 100
      And I should see correct jurisdiction
      And I should see Form number
      And I should see Less than £4,250 to be Yes
      And I should see Between £4,250 and £15,999 to be No
      And I should see More than £16,000 to be No
      And I should see Benefits to be No
      And I should see Children to be No
      And I should see Income with value 1500
      And I should see Income period to be last calendar month
      And I should see Income period to be last calendar month
      And I should see Applicant income type to be wages and universal credit
      And I should see Declaration statement to be applicant

      And press Start now
      Then I am on part payment ready to process page

      When I am choose Yes and press Next
      Then I am on check details pages for part payment process page

      And I should see today date received date
      And I should see no refund
      And I should see Full name
      And I should see dob
      And I should see single status
      And I should see Fee 100
      And I should see correct jurisdiction
      And I should see Form number
      And I should see Less than £4,250 to be Yes
      And I should see Between £4,250 and £15,999 to be No
      And I should see More than £16,000 to be No
      And I should see Benefits to be No
      And I should see Children to be No
      And I should see Income with value 1500
      And I should see Income period to be last calendar month
      And I should see Income period to be last calendar month
      And I should see Applicant income type to be wages and universal credit
      And I should see Declaration statement to be applicant
      And I should see "The applicant has paid £40 towards the fee" text
      And press Complete processing
      Then I should see Processing complete
      When I click Back to start
      Then I should see that my last application has processed status














