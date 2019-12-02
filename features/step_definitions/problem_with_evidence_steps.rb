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
