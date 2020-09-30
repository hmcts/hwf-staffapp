And("there is an application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  fill_in 'Email', with: user.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
end

And("I am on an application waiting for evidence") do
  dashboard_page.content.waiting_for_evidence_application_link.click
  expect(page).to have_current_path(%r{/evidence})
end

When("I click on start now to process the evidence") do
  click_on 'Start now', visible: false
end

Then("I should be taken to a page asking me if the evidence ready to process") do
  expect(evidence_accuracy_page).to have_current_path(%r{/evidence/1/accuracy})
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
  expect(evidence_page.content.evidence_summary[0]).to have_personal_details
end

Then("I should see the application details") do
  expect(evidence_page.content.evidence_summary[1]).to have_application_details
end

Then("I should see the applicants benefit details") do
  expect(evidence_page.content.evidence_summary[2]).to have_benefits
end

Then("I should see the applicants income details") do
  expect(evidence_page.content.evidence_summary[3]).to have_income
end

Then("I should see whether the applicant is eligible for help with fees") do
  expect(evidence_page.content).to have_full_refund_header
end

Then("I should see the processing summmary") do
  expect(evidence_page.content).to have_processing_summary
end

When("I click on return application") do
  expect(page).to have_current_path(%r{/evidence})
  evidence_page.content.evidence_can_not_be_processed.click
  click_link 'Return application', visible: false
end

Then("I should be taken to the problem with evidence page") do
  expect(page).to have_text 'What is the problem?'
end

When("I submit that the evidence is correct") do
  evidence_accuracy_page.content.correct_evidence.click
  next_page
end

Then("I should be taken to the evidence income page") do
  expect(evidence_page).to have_current_path(%r{/evidence/1/income})
  expect(evidence_page.content).to have_header
end

When(/^I submit (\d+) as the income$/) do |income|
  expect(page).to have_current_path(%r{/evidence/1/income})
  fill_in 'Total monthly income from evidence', with: income
  next_page
end

Then("I see the amount to be refunded should be £656.66") do
  expect(evidence_page).to have_current_path(%r{/evidence/1/result})
  expect(evidence_page.content).to have_full_refund_header
end

Then("I see the amount to be refunded should be £5") do
  expect(evidence_page.content).to have_partial_refund_header
end

Then("I see that the applicant is not eligible for help with fees") do
  expect(evidence_page.content).to have_not_eligable_header
end

When("I submit that there is a problem with evidence") do
  evidence_accuracy_page.content.problem_with_evidence.click
  next_page
end

Then("I should be taken to the reason for rejecting the evidence page") do
  expect(reason_for_rejecting_evidence_page).to have_current_path(%r{/evidence/accuracy_incorrect_reason/1})
  expect(reason_for_rejecting_evidence_page.content).to have_header
end

When("I click on next without making a selection on the evidence page") do
  expect(evidence_accuracy_page).to have_current_path(%r{/evidence/1/accuracy})
  next_page
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
  expect(evidence_accuracy_page).to have_current_path(%r{/accuracy})
  evidence_accuracy_page.content.correct_evidence.click
  click_on 'Next', visible: false
  expect(evidence_page).to have_current_path(%r{/income})
  find_field('Total monthly income from evidence', visible: false).set('500')
  click_on 'Next', visible: false
  expect(evidence_page).to have_current_path(%r{/result})
  expect(page).to have_text '✓ Eligible for help with fees'
  click_on 'Next', visible: false
  expect(evidence_page).to have_current_path(%r{/summary})
end

Given("I use the browser back button") do
  page.go_back
end

Given("I should see a message telling me that the application has been processed") do
  expect(page).to have_text 'This application has been processed. You can’t edit any details.'
end

Then("I should see the evidence details on the summary page") do
  expect(evidence_page.content.evidence_summary[0].summary_row[0].text).to eq 'Evidence'
  expect(evidence_page.content.evidence_summary[0].summary_row[1].text).to have_text 'Ready to process Yes Change Ready to process'
  expect(evidence_page.content.evidence_summary[0].summary_row[2].text).to have_text 'Income £500 Change Income'
end

When("I complete processing") do
  complete_processing
  click_on 'Back to start', visible: false
end

Then("I should see select from one of the problem options error message") do
  expect(page).to have_text 'What is the problem?'
end

Then("the application should have the status of processed") do
  expect(evidence_page.content.table_row[1]).to have_text 'processed'
end
