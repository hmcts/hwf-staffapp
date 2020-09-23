Given("I am on the savings and investments part of the application") do
  savings_investments_page.go_to_savings_investment_page
end

When("I successfully submit less than £3000") do
  savings_investments_page.submit_less_than
end

When("I click on more than £3000") do
  savings_investments_page.submit_more_than
end

And("I submit how much they have") do
  expect(savings_investments_page.content).to have_savings_amount_label
  expect(page).to have_text 'Rounded to the nearest £'
  savings_investments_page.content.application_amount.set '10000.01'
  click_button('Next')
end

Then("I should be taken to the benefits page") do
  expect(benefits_page).to have_current_path(%r{/benefits})
  expect(benefits_page.content).to have_header
end
