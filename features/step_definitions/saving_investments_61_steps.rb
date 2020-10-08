Given("As a staff who is processing HwF paper application on the staff app,") do
  start_application
  dashboard_page.process_application
end

And("The applicant is over 61 years old") do
  personal_details_page.submit_required_personal_details_61
  application_details_page.submit_fee_600
end

When("I exceed saving limit") do
  savings_investments_page.submit_more_than
end

Then("I should see the question {string} with options {string} and {string}") do |string, string2, string3|
  expect(page).to have_text(string)
  expect(page).to have_text(string2)
  expect(page).to have_text(string3)
end

And("The applicant is under 61 years old") do
  personal_details_page.submit_required_personal_details
  application_details_page.submit_fee_600
end

Then("I should see the question {string} and a text field") do |string|
  expect(page).to have_text(string)
end
