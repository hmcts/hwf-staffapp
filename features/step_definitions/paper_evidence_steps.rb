Given("I am on the paper evidence part of the application") do
  expect(personal_details_page).to have_current_path(%r{/personal_informations})
  go_to_paper_evidence_page
end

When("I successfully submit my required paper evidence details") do
  paper_evidence_page.submit_evidence_yes
end

Then("I should be taken to the summary page") do
  expect(summary_page).to have_current_path(%r{/summary})
  expect(summary_page).to be_displayed
  expect(summary_page.content).to have_header
end
