Given("I have completed an application") do
  go_to_summary_page
end

Given("I am on the summary page") do
  expect(current_path).to eq '/applications/2/summary'
  expect(summary_page.content).to have_header
end

When("I successfully submit my application") do
  summary_page.complete_processing
end

Then("I should be taken to the confirmation page") do
  expect(current_path).to eq '/applications/2/confirmation'
  expect(confirmation_page.content).to have_eligible
end
