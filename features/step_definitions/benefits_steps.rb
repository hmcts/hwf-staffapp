Given("I am on the benfits part of the application") do
  submit_required_personal_details
  submit_fee_600
  submit_savings_less_than
  expect(current_path).to eq '/applications/2/benefits'
  expect(benefits_page.content).to have_header
end

When("I answer yes to the benefits question") do
  benefits_page.submit_benefits_yes
end

Then("I should be asked about paper evidence") do
  expect(current_path).to eq '/applications/2/benefit_override/paper_evidence'
end
