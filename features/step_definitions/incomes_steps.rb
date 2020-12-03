Given("I am on the incomes part of the application") do
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_required_personal_details
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(incomes_page.content).to have_header
end

When("I answer yes to does the applicant financially support any children") do
  incomes_page.content.radio[1].click
  expect(page).to have_text 'Rounded to the nearest £'
end

When("I answer no to does the applicant financially support any children") do
  incomes_page.submit_incomes_no
end

When("I submit the total number of children") do
  expect(incomes_page.content).to have_number_of_children_hint
  fill_in 'Number of children', with: '2'
end

When("I submit the total monthly income") do
  incomes_page.submit_incomes_1200
end

But("I do not fill in the number of children or total monthly income") do
  incomes_page.click_next
end

Then("I should see enter number of children error message") do
  expect(incomes_page.content).to have_number_of_children_error
end

And("I should see enter total monthly income error message") do
  expect(incomes_page.content).to have_total_monthly_income_error
end
