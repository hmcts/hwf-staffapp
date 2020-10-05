When("I am on the problem with evidence page") do
  go_to_problem_with_evidence_page
  problem_with_evidence_page.content.wait_until_header_visible
  expect(problem_with_evidence_page.content).to have_header
end

Then("I should be taken to the return letter page") do
  expect(return_letter_page.content).to have_header
  expect(return_letter_page).to have_current_path(%r{/evidence/1/return_letter})
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
  click_button('Next')
end
