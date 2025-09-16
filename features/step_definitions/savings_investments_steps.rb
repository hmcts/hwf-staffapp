Given("I am on the savings and investments part of the application") do
  go_to_savings_investment_page
end

Given("I am on the savings and investments part of the application and over 66") do
  go_to_savings_investment_page_over_66
end

When("I successfully submit less than £4250") do
  savings_investments_page.submit_less_than_ucd
end

When("I click between £4250 and £15999 under 66 years old") do
  savings_investments_page.submit_between_under_66_ucd
end

When("I click between £4250 and £15999 over 66 years old") do
  savings_investments_page.submit_between_over_66_ucd
end

Then("I should see error message not 66") do
  expect(savings_investments_page.content).to have_not_66_error
end

And("I enter £5000") do
  savings_investments_page.submit_amount_5000
end

And("I enter £15000") do
  savings_investments_page.submit_amount_15000
end

When("I click on more than £16000") do
  savings_investments_page.submit_more_than_ucd
end

Then("My application gets no remission") do
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  complete_processing
  expect(confirmation_page.content).to have_ineligible
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

When("I submit a value less than £4250") do
  savings_investments_page.submit_amount_1000
end

Then("I should see a 'must be greater than or equal to 4250' error") do
  expect(savings_investments_page.content).to have_header
  expect(savings_investments_page.content).to have_inequality_error
end

When("I submit a non-numerical input") do
  savings_investments_page.submit_abc
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

Then("I remain on the savings and investments page") do
  expect(savings_investments_page.content).to have_header
end
