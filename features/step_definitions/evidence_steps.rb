And("there is an application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page.content).to have_find_an_application_heading
end

And("I am on an application waiting for evidence") do
  dashboard_page.content.waiting_for_evidence_application_link.click
  expect(waiting_for_evidence_applications_page.content).to have_header
end

When("I click on start now to process the evidence") do
  click_on 'Start now', visible: false
end

Then("I should be taken to a page asking me if the evidence ready to process") do
  expect(evidence_accuracy_page.content).to have_header
end

When("I click on what to do if the evidence cannot be processed") do
  evidence_page.content.evidence_can_not_be_processed.click
end

Then("I should see instructions with a deadline to submit the evidence") do
  expires_at = @application.evidence_check.expires_at.strftime("%Y-%m-%d")
  expect(evidence_page.content.evidence_deadline.text).to have_content "Evidence needs to arrive by #{expires_at}"
end

Then("I should see the applicants personal details") do
  expect(evidence_page.content).to have_personal_details
end

Then("I should see the date received and fee status") do
  expect(evidence_page.content).to have_date_received_and_fee_status_details
end

Then("I should see the application details") do
  expect(evidence_page.content).to have_application_details
end

Then("I should see the applicants benefit details") do
  expect(evidence_page.content).to have_benefits
end

Then("I should see the applicants income details") do
  expect(evidence_page.content).to have_income
end

Then("I should see whether the applicant is eligible for help with fees") do
  expect(evidence_page.content).to have_full_refund_header
end

Then("I should see the processing summmary") do
  expect(evidence_page.content).to have_processing_summary
end

When("I click on return application") do
  expect(evidence_page.content).to have_waiting_for_evidence_instance_header
  evidence_page.content.evidence_can_not_be_processed.click
  click_link 'Return application', visible: false
end

Then("I should be taken to the problem with evidence page") do
  expect(page).to have_text 'What is the problem?'
end

When("I submit that the evidence is correct") do
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.correct_evidence.click
  evidence_accuracy_page.click_next
end

Then("I should be taken to the evidence income page") do
  expect(evidence_page.content).to have_header
end

When(/^I submit (\d+) as the income$/) do |income|
  expect(evidence_page.content).to have_header
  fill_in 'Total monthly income from evidence', with: income
  evidence_page.click_next
end

Then("I see the amount to be refunded should be £656.66") do
  expect(evidence_result_page.content).to have_header
  expect(evidence_result_page.content).to have_eligable_header
end

Then("I see the amount to be refunded should be £5") do
  expect(evidence_page.content).to have_partial_refund_header
end

Then("I see that the applicant is not eligible for help with fees") do
  expect(evidence_page.content).to have_not_eligable_header
end

When("I submit that there is a problem with evidence") do
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.problem_with_evidence.click
  evidence_accuracy_page.click_next
end

Then("I should be taken to the reason for rejecting the evidence page") do
  expect(reason_for_rejecting_evidence_page.content).to have_header
end

When("I click on next without making a selection on the evidence page") do
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.click_next
end

Then("I should see this question must be answered error message") do
  evidence_accuracy_page.content.wait_until_header_visible
  expect(page).to have_text 'You need to say whether the evidence can be processed'
end

Then("I see that the applicant needs to make a payment towards the fee") do
  expect(evidence_page.content).to have_refund_header
end

Given("I have successfully submitted the evidence") do
  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.correct_evidence.click
  evidence_accuracy_page.click_next
  expect(evidence_income_page.content).to have_header
  find_field('Total monthly income from evidence', visible: false).set('500')
  evidence_page.click_next
  expect(evidence_result_page.content).to have_header
  expect(evidence_result_page.content).to have_eligable_header
  evidence_result_page.click_next
  expect(summary_page.content).to have_header
end

Given("I use the browser back button") do
  page.go_back
end

Given("I should see a message telling me that the application has been processed") do
  expect(page).to have_text 'This application has been processed. You can’t edit any details.'
end

Then("I should see the evidence details on the summary page") do
  expect(evidence_page.content.evidence).to have_text 'Evidence'
  expect(evidence_page.content.evidence_summary[0].summary_row[0].text).to have_text 'Ready to process Yes Change'
  expect(evidence_page.content.evidence_summary[0].summary_row[1].text).to have_text 'Total income 500 Change'
end

When("I complete processing") do
  complete_processing
end

Then("I should see select from one of the problem options error message") do
  expect(page).to have_text 'What is the problem?'
end

Then("the application should have the status of processed") do
  expect(evidence_page.content.table_row[1]).to have_text 'processed'
end
