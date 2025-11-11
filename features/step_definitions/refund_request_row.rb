Given("An applicant has submitted an online application where fee has been paid") do
  @online_application = FactoryBot.create(:online_application, :with_reference, :completed, :with_refund, ni_number: Settings.dwp_mock.ni_number_yes.first)
end

When("I process the online application to the check details page") do
  reference = @online_application.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  # stub_dwp_response_as_ok_request
  process_online_application_page.click_next
  expect(process_online_application_page.content).to have_check_details_header
end

Given("An applicant has submitted an online application where fee has not been paid") do
  @online_application = FactoryBot.create(:online_application, :with_reference, :completed, ni_number: Settings.dwp_mock.ni_number_yes.first)
end

When("I process a paper application where fee has been paid to the check details page") do
  dashboard_page.process_application
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_as_refund_case_no_decimal
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_1200
  expect(summary_page.content).to have_header
end

When("An applicant has submitted a waiting for evidence online application where fee has been paid") do
  user = FactoryBot.create(:user)
  waiting_evidence_application_ni(user)
end

When("I process a part payment paper application where fee has been paid to the check details page") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_as_refund_case_no_decimal
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_1200
  expect(summary_page.content).to have_header
end

Then("There will be a row under the Application details section labelled Refund request Yes") do
  expect(summary_page.content.summary_section[1].text).to have_content("Refund request Yes")
end

Then("There will be a row under the Application details section labelled Refund request No") do
  expect(summary_page.content.summary_section[1].text).to have_content("Refund request No")
end

When("I go to the waiting for evidence application") do
  dashboard_page.content.last_application_link.click
  expect(evidence_page.content).to have_waiting_for_evidence_instance_header
end

Given("there is an application waiting for evidence where fee has not been paid") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page.content).to have_find_an_application_heading
end
