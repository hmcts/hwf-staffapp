Given("I am a staff member with CCMCC office and I process a paper-based income application") do
  sign_in_as_ccmcc_office_user
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
end

Given("I enter the date of birth of the applicant as under 15 years old") do
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_under_15
end

Given("I enter the date of birth of the applicant as 15 years old") do
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_exactly_15
end

Given("I enter the date of birth of the applicant as over 15 years old") do
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_16
end

Given("when I get to the 'Summary page'") do
  complete_application
end

When("I get to the 'Summary page'") do
  complete_application
end

When("the application is completed") do
  complete_processing
end

Then("I should see a row '15 and under' under the date of birth") do
  expect(summary_page.content.summary_section[0].list_row[3].text).to have_content '15 and under Yes Change 15 and under'
end

Then("I should not see a row '15 and under' under the date of birth") do
  expect(summary_page.content.summary_section[0].list_row[3].text).to have_no_content '15 and under Yes Change 15 and under'
end

Then("the application will skip the evidence check") do
  expect(evidence_page.content).to have_application_complete
  expect(confirmation_page.content).to have_eligible
  expect(evidence_page.content.evidence_summary[0].summary_row[2]).to have_text 'Income ✓ Passed'
end

Then("the application will not skip the evidence check") do
  expect(evidence_page.content).to have_waiting_for_evidence_header
  expect(evidence_page.content.evidence_summary[0].summary_row[2]).to have_text 'Income Waiting for evidence'
end

# rubocop:disable MethodLength
# rubocop:disable Metrics/AbcSize
def complete_application
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_6000
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_0
  expect(summary_page.content).to have_header
end
# rubocop:enable MethodLength
# rubocop:enable Metrics/AbcSize
