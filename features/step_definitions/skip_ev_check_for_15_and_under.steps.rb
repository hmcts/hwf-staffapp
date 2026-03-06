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

Then("I should see a row '16 and over' under the date of birth with Yes value") do
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_content 'Applicant over 16 Yes Change Applicant over 16'
end

Then("I should see a row '16 and over' under the date of birth with No value") do
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_content 'Applicant over 16 No Change Applicant over 16'
end

Then("the application will skip the evidence check") do
  expect(evidence_page.content).to have_application_complete
  expect(confirmation_page.content).to have_eligible
  expect(evidence_page.content.evidence_summary[0].summary_row[1]).to have_text 'Income ✓ Passed'
end

Then("the application will not skip the evidence check") do
  expect(evidence_page.content).to have_waiting_for_evidence_header
  expect(evidence_page.content.evidence_summary[0].summary_row[1]).to have_text 'Income Waiting for evidence'
end

# rubocop:disable Metrics/AbcSize
def complete_application
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_0
  expect(summary_page.content).to have_header
end
# rubocop:enable Metrics/AbcSize
