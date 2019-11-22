When("I am on the problem with evidence page") do
  sign_in_page.load_page
  sign_in_page.user_account
  problem_with_evidence_page.go_to_problem_with_evidence_page
  expect(problem_with_evidence_page.content).to have_header
end

When("I successfully submit one of the problems") do
  problem_with_evidence_page.content.not_arrived_too_late.click
  next_page
end

Then("I am taken to the rejection letter page") do
  expect(current_path).to eq '/evidence/1/return_letter'
end

When("I submit the page with not arrived or too late") do
  problem_with_evidence_page.content.not_arrived_too_late.click
  next_page
end

When("I submit the page with citizen not proceeding") do
  problem_with_evidence_page.content.not_proceeding.click
  next_page
end

When("I submit the page with staff error") do
  problem_with_evidence_page.content.staff_error.click
  next_page
end

Then("I should see evidence has not arrived or too late letter template") do
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'Reference: PA19-000002'
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'As we haven’t received any information, we’re unable to process your application'
end

Then("I should see a not proceeding application letter template") do
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'Reference: PA19-000002'
  expect(return_letter_page.content.evidence_confirmation_letter.text).to include 'we are returning the application as you no longer wish to proceed'
end

When("I click on finish") do
  click_button('Finish')
end

When("I click on staff error") do
  problem_with_evidence_page.content.staff_error.click
end

When("I submit the details of the staff error") do
  fill_in 'Please add details of the staff error', with: 'These are the details of the staff error'
  next_page
end
