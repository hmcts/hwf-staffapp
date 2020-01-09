And("there is an application waiting for evidence") do
  sign_in_page.load_page
  sign_in_page.user_account
  waiting_evidence_application
  waiting_evidence_application
end

And("I am on an application waiting for evidence") do
  click_link("#{reference_prefix}-000002")
end

When("I click on start now to process the evidence") do
  click_link('Start now')
end

Then("I should be taken to a page asking me if the evidence ready to process") do
  expect(evidence_accuracy_page.content).to have_header
  expect(current_path).to end_with '/evidence/1/accuracy'
end

When("I click on what to do if the evidence cannot be processed") do
  evidence_page.content.evidence_can_not_be_processed.click
end

Then("I should see instructions with a deadline to submit the evidence") do
  date_received = (Time.zone.now + 2.weeks).strftime("%Y-%m-%d")
  expect(evidence_page.content.evidence_deadline.text).to have_content "Evidence needs to arrive by #{date_received}"
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
  expect(evidence_page.content).to have_eligable_header
end

Then("I should see the processing summmary") do
  date_processed = Time.zone.now.strftime('%-d %B %Y')
  expect(evidence_page.content).to have_processing_summary
  expect(evidence_page.content.text).to have_content date_processed
end

When("I click on return application") do
  evidence_page.content.evidence_can_not_be_processed.click
  click_link('Return application')
end

Then("I should be taken to the problem with evidence page") do
  expect(problem_with_evidence_page.content).to have_header
end

When("I submit that the evidence is correct") do
  evidence_accuracy_page.content.correct_evidence.click
  next_page
end

Then("I should be taken to the evidence income page") do
  expect(current_path).to include '/evidence/1/income'
  expect(evidence_page.content).to have_header
end

When(/^I submit (\d+) as the income$/) do |income|
  fill_in 'Total monthly income from evidence', with: income
  next_page
end

Then("I see that the applicant is eligible for help with fees") do
  expect(evidence_page.content).to have_eligable_header
end

Then("I see that the applicant is not eligible for help with fees") do
  expect(evidence_page.content).to have_not_eligable_header
end

When("I submit that there is a problem with evidence") do
  evidence_accuracy_page.content.problem_with_evidence.click
  next_page
end

Then("I should be taken to the reason for rejecting the evidence page") do
  expect(current_path).to end_with '/evidence/accuracy_incorrect_reason/1'
  expect(reason_for_rejecting_evidence_page.content).to have_header
end

Then("I should see this question must be answered error message") do
  expect(evidence_accuracy_page.content).to have_answer_question_error
end

Then("I see that the applicant needs to make a payment towards the fee") do
  expect(evidence_page.content).to have_part_payment
end

Given("I have successfully submitted the evidence") do
  click_link('Start now')
  evidence_accuracy_page.content.correct_evidence.click
  next_page
  fill_in 'Total monthly income from evidence', with: '500'
  next_page
  click_link('Next')
end

Given("I have successfully processed the evidence") do
  evidence_page.processed_evidence
end

Given("I use the browser back button") do
  page.go_back
end

Given("I should see a message telling me that the application has been processed") do
  expect(evidence_page.content).to have_error_message
end

Then("I should see the evidence details on the summary page") do
  expect(current_path).to end_with '/evidence/1/summary'
  expect(evidence_page.content.evidence_summary[0].summary_row[0].text).to eq 'Evidence'
  expect(evidence_page.content.evidence_summary[0].summary_row[1].text).to eq 'Ready to process Yes ChangeReady to process'
  expect(evidence_page.content.evidence_summary[0].summary_row[2].text).to eq 'Income £500 ChangeIncome'
end

When("I complete processing") do
  complete_processing
  back_to_start
end

Then("I should see select from one of the problem options error message") do
  problem_with_evidence_page.content.header
end
