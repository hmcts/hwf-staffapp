Given("I am on the ask a manager page") do
  start_application
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_required_personal_details
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_10001
  expect(approve_page.content).to have_header
end

When("I successfully submit a manager name") do
  approve_page.content.wait_until_first_name_visible
  approve_page.content.first_name.set 'Mary'
  approve_page.content.last_name.set 'Smith'
  approve_page.click_next
end

Then("I am taken to the savings and investments page") do
  expect(savings_investments_page.content).to have_header
end

When("I click on next without supplying a manager name") do
  approve_page.click_next
end

When("I click on next after only supplying manager first name") do
  approve_page.content.wait_until_first_name_visible
  approve_page.submit_first_name
  approve_page.click_next
end

When("I click on next after only supplying manager last name") do
  approve_page.content.wait_until_last_name_visible
  approve_page.submit_last_name
  approve_page.click_next
end

Then("I should see enter manager name error message") do
  expect(approve_page.content).to have_error_first_name
  expect(approve_page.content).to have_error_last_name
  expect(approve_page.content).to have_header
end

Then("I should see enter manager first name error message") do
  expect(approve_page.content).to have_error_last_name
  expect(approve_page.content).to have_header
end

Then("I should see enter manager last name error message") do
  expect(approve_page.content).to have_error_first_name
  expect(approve_page.content).to have_header
end
