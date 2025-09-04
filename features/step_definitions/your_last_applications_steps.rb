Given("I fill in the fee status of the application") do
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
end

Given("I fill in personal details of the application") do
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
end

Given("I fill in the application details") do
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
end

Given("I abandon the application") do
  expect(savings_investments_page.content).to have_header
  savings_investments_page.go_home
end

When("I open my last application") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.content.last_application_link.click
end

Then("I should see the personal details populated with information") do
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  expect(personal_details_page.content.application_first_name['value']).to eq 'John Christopher'
  personal_details_page.click_next
end

Then("I should see the application details populated with information") do
  expect(application_details_page.content).to have_header
  expect(application_details_page.content.form_input['value']).to eq 'C100'
end
