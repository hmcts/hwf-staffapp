Given("I am on the savings and investments part of the application") do
  go_to_savings_investment_page
  expect(savings_investments_page.content).to have_header
end

When("I successfully submit less than £4250") do
  savings_investments_page.submit_less_than_ucd
end

When("I successfully submit less than £3000") do
  savings_investments_page.submit_less_than
end

When("I click on more than £3000") do
  savings_investments_page.submit_more_than
end

When("I submit how much they have") do
  expect(savings_investments_page.content).to have_savings_amount_label
  expect(page).to have_text 'Rounded to the nearest £'
  savings_investments_page.content.application_amount.set '10000.01'
  savings_investments_page.click_next
end

Then("I should be taken to the benefits page") do
  expect(benefits_page.content).to have_header
end

When("I don't submit how much they have") do
  expect(savings_investments_page.content).to have_savings_amount_label
  expect(savings_investments_page).to have_text 'Rounded to the nearest £'
  savings_investments_page.click_next
end

Then("I should see a 'Please enter the amount of savings and investments' error") do
  expect(savings_investments_page.content).to have_header
  expect(savings_investments_page.content).to have_blank_error
end

When("I submit a value less than £3000") do
  expect(savings_investments_page).to have_text 'Rounded to the nearest £'
  savings_investments_page.content.application_amount.set '100'
  savings_investments_page.click_next
end

Then("I should see a 'must be greater than or equal to 3000' error") do
  expect(savings_investments_page.content).to have_header
  expect(savings_investments_page.content).to have_inequality_error
end

When("I submit a non-numerical input") do
  expect(savings_investments_page).to have_text 'Rounded to the nearest £'
  savings_investments_page.content.application_amount.set 'abc'
  savings_investments_page.click_next
end

Then("I should see a 'The value that you entered is not a number' error") do
  expect(savings_investments_page.content).to have_header
  expect(savings_investments_page.content).to have_non_numerical_error
end

When("I click next without selecting a savings and investments option") do
  expect(savings_investments_page.content).not_to have_savings_amount_label
  expect(savings_investments_page).to have_no_text 'Rounded to the nearest £'
  savings_investments_page.click_next
end

Then("I should see a 'Please answer the savings question' error") do
  expect(savings_investments_page.content).to have_header
  expect(savings_investments_page.content).to have_no_answer_error
end
