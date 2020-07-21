Given("I am on the ask a manager page") do
  approve_page.go_to_approve_page
  expect(current_path).to include 'approve'
  expect(approve_page.content).to have_header
end

When("I successfully submit a manager name") do
  approve_page.submit_full_name
end

Then("I am taken to the savings and investments page") do
  expect(current_path).to include 'savings_investments'
  expect(savings_investments_page.content).to have_header
end

When("I click on next without supplying a manager name") do
  next_page
end

Then("I should see enter manager name error message") do
  expect(approve_page.content).to have_error_first_name
  expect(approve_page.content).to have_error_last_name
end
