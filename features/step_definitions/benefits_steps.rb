Given("I am on the benfits part of the application") do
  benefits_page.go_to_benefits_page
  expect(current_path).to end_with 'benefits'
  expect(benefits_page.content).to have_header
end

When("I answer yes to the benefits question") do
  expect(benefits_page.content).to have_benefit_question
  benefits_page.submit_benefits_yes
end

When("I answer no to the benefits question") do
  expect(benefits_page.content).to have_benefit_question
  benefits_page.submit_benefits_no
end

Then("I should be asked about paper evidence") do
  expect(current_path).to end_with 'benefit_override/paper_evidence'
end

Then("I should be taken to the incomes page") do
  expect(incomes_page).to be_displayed
  expect(incomes_page.content).to have_header
end
