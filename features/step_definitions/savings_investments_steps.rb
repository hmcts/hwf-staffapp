Given("I am on the savings and investments part of the application") do
  submit_required_personal_details
  submit_fee_600
end

When("I successfully submit less than £3000") do
  savings_investments_page.submit_less_than
end

When("I click on more than £3000") do
  savings_investments_page.submit_more_than
end

And("I submit how much they have") do
  expect(savings_investments_page.content).to have_savings_amount_label
  savings_investments_page.content.application_amount.set '10000'
  next_page
end

Then("I should be taken to the benefits page") do
  expect(current_path).to include 'benefits'
  expect(benefits_page.content).to have_header
end
