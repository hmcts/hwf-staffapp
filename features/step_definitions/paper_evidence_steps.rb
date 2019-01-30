Given("I am on the paper evidence part of the application") do
  submit_required_personal_details
  submit_fee_600
  submit_savings_less_than
  submit_benefits_yes
end

When("I successfully submit my required paper evidence details") do
  paper_evidence_page.submit_evidence_yes
end

Then("I should be taken to the summary page") do
  expect(current_path).to include 'summary'
  expect(summary_page.content).to have_header
end
