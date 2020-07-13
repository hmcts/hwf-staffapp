When("I am on the problem with evidence page") do
  sign_in_page.load_page
  sign_in_page.user_account
  problem_with_evidence_page.go_to_problem_with_evidence_page
  expect(problem_with_evidence_page.content).to have_header
end

Then("I should be taken to the return letter page") do
  expect(return_letter_page.content).to have_header
  expect(current_path).to include '/evidence/1/return_letter'
end

When("I submit the page with not arrived or too late") do
  problem_with_evidence_page.submit_not_arrived_too_late
end

When("I submit the page with citizen not proceeding") do
  problem_with_evidence_page.submit_not_proceeding
end

When("I click on staff error") do
  problem_with_evidence_page.content.staff_error.click
end

When("I submit the details of the staff error") do
  fill_in 'Please add details of the staff error', with: 'These are the details of the staff error'
  click_on 'Next', visible: false
end
