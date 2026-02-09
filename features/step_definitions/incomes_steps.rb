Given("I am on the income part of the application") do
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_required_personal_details
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(children_page.content).to have_header
  children_page.no_children
  expect(income_kind_applicant_page.content).to have_header
  income_kind_applicant_page.submit_wages
  expect(incomes_page.content).to have_header
end

When("I submit the total monthly income") do
  incomes_page.submit_income
end

When("I do not submit the total monthly income") do
  incomes_page.submit_income_no
end

And("I should see enter total monthly income error message") do
  expect(incomes_page.content).to have_total_monthly_income_error
end

Then("I am on the declaration page") do
  expect(declaration_page.content).to have_header
end
