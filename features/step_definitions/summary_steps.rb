Given("I have completed an application") do
  go_to_summary_page
end

Given("I am on the summary page") do
  expect(current_path).to include 'summary'
  expect(summary_page.content).to have_header
end

When("I successfully submit my application") do
  summary_page.complete_processing
end

Then("I should be taken to the confirmation page") do
  expect(current_path).to include 'confirmation'
  expect(confirmation_page.content).to have_eligible
end

When("I see benefit summary") do
  expect(summary_page.content.summary_section[3].summary_header.text).to eq 'Benefits'
end

Then("I should see I have declared benefits in this application") do
  expect(summary_page.content.summary_section[3]).to have_benefit_declared_yes
end

Then("I have provided the correct evidence") do
  expect(summary_page.content.summary_section[3]).to have_evidence_provided_yes
end
