Given("I am on the benfits part of the application") do
  benefits_page.go_to_benefits_page
  expect(current_path).to include 'benefits'
  expect(benefits_page.content).to have_header
end

When("I answer yes to the benefits question") do
  benefits_page.submit_benefits_yes
end

Then("I should be asked about paper evidence") do
  expect(current_path).to include 'benefit_override/paper_evidence'
end
