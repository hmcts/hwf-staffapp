Given("An applicant has submitted an online application where fee has been paid") do
  FactoryBot.create(:online_application, :with_reference, :completed, :with_refund)
end

When("I process the online application to the check details page") do
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.group[1].jurisdiction[0].click
  process_online_application_page.click_next
  expect(page).to have_current_path(%r{/online_applications})
end

Given("An applicant has submitted an online application where fee has not been paid") do
  FactoryBot.create(:online_application, :with_reference, :completed)
end

When("I process a paper application where fee has been paid to the check details page") do
  dashboard_page.process_application
  expect(personal_details_page).to have_current_path(/personal_informations/)
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page).to have_current_path(/details/)
  application_details_page.submit_as_refund_case_no_decimal
  expect(savings_investments_page).to have_current_path(/savings_investments/)
  savings_investments_page.submit_less_than
  expect(benefits_page).to have_current_path(/benefits/)
  benefits_page.submit_benefits_no
  expect(incomes_page).to have_current_path(/incomes/)
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_1200
  expect(summary_page).to have_current_path(/summary/)
end

When("An applicant has submitted a waiting for evidence online application where fee has been paid") do
  user = FactoryBot.create(:user)
  waiting_evidence_application_ni(user)
end

When("I process a part payment paper application where fee has been paid to the check details page") do
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.process_application
  expect(personal_details_page).to have_current_path(/personal_informations/)
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page).to have_current_path(/details/)
  application_details_page.submit_as_refund_case_no_decimal
  expect(savings_investments_page).to have_current_path(/savings_investments/)
  savings_investments_page.submit_less_than
  expect(benefits_page).to have_current_path(/benefits/)
  benefits_page.submit_benefits_no
  expect(incomes_page).to have_current_path(/incomes/)
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_1200
  expect(summary_page).to have_current_path(/summary/)
end

Then("There will be a row under the Application details section labelled Refund request Yes") do
  expect(summary_page.content.summary_section[1].text).to have_content("Refund request Yes")
end

Then("There will be a row under the Application details section labelled Refund request No") do
  expect(summary_page.content.summary_section[1].text).to have_content("Refund request No")
end

When("I go to the waiting for evidence application") do
  dashboard_page.content.last_application_link.click
  expect(page).to have_current_path(%r{/evidence/[0-9]+})
  expect(page).to have_content(/Waiting for evidence/)
end

Given("there is an application waiting for evidence where fee has not been paid") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_current_path('/')
end
