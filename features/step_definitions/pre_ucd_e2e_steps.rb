Given('UCD changes are inactive') do
  disable_feature_switch('band_calculation')
end

When('I successfully submit my required application details pre UCD') do
  application_details_page.submit_fee_600_pre_ucd
end

When('I sucessfully submit my savings and investments pre UCD') do
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
end

When('I submit the application signed by myself') do
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
end

Then('I should see check details page pre UCD') do
  expect(summary_page.content).to have_header
  expect(summary_page.content.summary_section[2].list_row[0].text).to have_content 'Less than £3,000 Yes Change Less than £3,000'

  expect(summary_page.content).to have_personal_details_header
  expect(summary_page.content.summary_section[0].list_row[0].text).to have_content 'Full name John Christopher Smith Change Full name'
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_content 'Date of birth 10 February 1986 Change Date of birth'
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_content 'Applicant over 16 Yes'
  expect(summary_page.content.summary_section[0].list_row[3].text).to have_content 'National Insurance number JR 05 40 08 D Change National Insurance number'
  expect(summary_page.content.summary_section[0].list_row[4].text).to have_content 'Status Single Change Status'
end

When("I answer yes to does the applicant financially support any children") do
  incomes_page.content.radio[1].click
  expect(page).to have_text 'Rounded to the nearest £'
end

When("I answer no to does the applicant financially support any children") do
  incomes_page.submit_income_no_pre_ucd
end

When("I submit the total number of children") do
  expect(incomes_page.content).to have_number_of_children_hint
  fill_in 'Number of children', with: '2'
end

When("I submit 50 total monthly income") do
  incomes_page.submit_incomes_50
end

When("I submit 1200 total monthly income") do
  incomes_page.submit_incomes_1200
end

When("I submit a refund application where refund date is within 3 months of application received date pre UCD") do
  application_details_page.submit_as_refund_case_pre_ucd
end

Given("There is an application pending pre UCD") do
  @current_user = FactoryBot.create(:user)
  @applicant = create_application_with_bad_request_result_pre_ucd_with(@current_user)
end

When("I complete processing the application pre UCD") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('online')

    expect(personal_details_page.content).to have_header
    personal_details_page.click_next
    expect(application_details_page.content).to have_header
    application_details_page.content.jurisdiction.click
    application_details_page.click_next
    expect(savings_investments_page.content).to have_header
    application_details_page.click_next
    expect(summary_page.content).to have_header
    complete_processing
  end
end

Then("I should be on the result page with the application status set to processed pre UCD") do
  expect(evidence_page.content).to have_result
  expect(evidence_page.content.evidence_summary[0].summary_row[0]).to have_text 'Savings and investments ✗ Failed'
end
