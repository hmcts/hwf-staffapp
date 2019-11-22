When("I am on the problem with evidence page") do
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

When("I click on staff error") do
  problem_with_evidence_page.content.staff_error.click
end

When("I submit the details of the staff error") do
  fill_in 'Please add details of the staff error', with: 'These are the details of the staff error'
  next_page
end

And("on the processed application I can see that the reason for not being processed is staff error") do
  click_button('Finish')
  click_link('PA19-000002')
  expect(evidence_page.content.table_row[1].text).to include 'Reason not processed: "staff_error"'
end
