Given("I am on the incomes part of the application") do
  incomes_page.go_to_incomes_page
  expect(incomes_page).to be_displayed
  expect(incomes_page.content).to have_header
  expect(incomes_page.content).to have_question
end

When("I answer yes to does the applicant financially support any children") do
  incomes_page.content.radio[1].click
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
  next_page
end

Then("I should see enter number of children error message") do
  expect(incomes_page.content).to have_number_of_children_error
end

And("I should see enter total monthly income error message") do
  expect(incomes_page.content).to have_total_monthly_income_error
end
