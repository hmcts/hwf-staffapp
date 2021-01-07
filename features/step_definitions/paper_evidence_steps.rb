Given("I am on the paper evidence part of the application") do
  expect(personal_details_page.content).to have_header
  go_to_paper_evidence_page
end

When("I successfully submit my required paper evidence details") do
  paper_evidence_page.submit_evidence_yes
end
