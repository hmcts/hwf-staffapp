And("I have processed an application") do
  start_application
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_yes
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
end

Given("I am on the confirmation page") do
  expect(confirmation_page.content).to have_reference_number_is
end

When("I click on back to start") do
  click_on_back_to_start
end

When("I click on back to list") do
  click_on_back_to_list
end

Then("I should be taken back to my dashboard") do
  expect(dashboard_page.content).to have_find_an_application_heading
end

Then("I should see my processed application in your last applications") do
  expect(dashboard_page.content).to have_processed_applications
  expect(dashboard_page.content).to have_last_application
end

Then("I should see that the applicant is eligible for help with fees") do
  expect(confirmation_page.content).to have_eligible
end

Then("I should see a help with fees reference number") do
  expect(confirmation_page.content).to have_reference_number_is
  reference_number = "#{reference_prefix}-000001"
  expect(confirmation_page.content.reference_number.text).to eql(reference_number)
end

Then("I should see the next steps") do
  expect(confirmation_page.content).to have_next_steps_steps
  expect(confirmation_page.content).to have_write_ref
  expect(confirmation_page.content).to have_copy_ref
  expect(confirmation_page.content).to have_can_be_issued
end

When("I can view the guides in a new window") do
  expect(confirmation_page.content.see_guides['href']).to have_text '/guide'
  expect(confirmation_page.content.see_guides['target']).to eq 'blank'
end
