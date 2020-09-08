Then("I am on the return letter page after selecting not arrived or too late") do
  sign_in_page.load_page
  sign_in_page.user_account
  problem_with_evidence_page.go_to_problem_with_evidence_page
  problem_with_evidence_page.submit_not_arrived_too_late
end

Then("I am on the return letter page after selecting citizen not proceeding") do
  sign_in_page.load_page
  sign_in_page.user_account
  problem_with_evidence_page.go_to_problem_with_evidence_page
  problem_with_evidence_page.submit_not_proceeding
end

Then("I am on the return letter page after selecting staff error") do
  sign_in_page.load_page
  sign_in_page.user_account
  problem_with_evidence_page.go_to_problem_with_evidence_page
  problem_with_evidence_page.submit_staff_error
end

Then("I should see evidence has not arrived or too late letter template") do
  reference = "#{reference_prefix}-000002"
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include "Reference: #{reference}"
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'As we haven’t received any information, we’re unable to process your application'
end

Then("I should see a not proceeding application letter template") do
  reference = "#{reference_prefix}-000002"
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include "Reference: #{reference}"
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'As you have explained that you no longer wish to proceed with your application for Help with Fees, we are returning this to you with the associated papers'
end

Then("I should see a evidence incorrect letter template") do
  reference = "#{reference_prefix}-000002"
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include "Reference: #{reference}"
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'There’s a problem with the documents you sent:'
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'How to pay'
end

Then("I should see next steps information for not received") do
  expect(return_letter_page.content.evidence_next_steps).to have_header
  expect(return_letter_page.content.evidence_next_steps).to have_not_received_text
  expect(return_letter_page.content.evidence_next_steps.root_element).to have_link
end

Then("I should see next steps information for evidence incorrect") do
  expect(return_letter_page.content.evidence_next_steps).to have_header
  expect(return_letter_page.content.evidence_next_steps).to have_evidence_incorrect_text
  expect(return_letter_page.content.evidence_next_steps).to have_link
end

Then("I should see next steps information for citizen not proceeding") do
  expect(return_letter_page.content.evidence_next_steps).to have_header
  expect(return_letter_page.content.evidence_next_steps).to have_citizen_not_proceeding_text
  expect(return_letter_page.content.evidence_next_steps.root_element).to have_link
end

Then("I should see no letter template") do
  expect(return_letter_page.content).to have_header
  expect(return_letter_page.content).not_to have_content('Next steps')
  expect(return_letter_page.content).not_to have_content('Yours sincerely')
end

When("I click on finish") do
  click_button('Finish')
end

And("on the processed application I can see that the reason for not being processed is staff error") do
  click_button('Finish')
  click_link("#{reference_prefix}-000001")
  expect(evidence_page.content.table_row[1].text).to include 'Reason not processed: "staff error"'
end
