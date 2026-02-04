Given("I process a paper application to the saving and investments page") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_with_no_answer_for_benefits
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_100
  expect(savings_investments_page.content).to have_header
end

Given("I submit a high savings amount and complete processing") do
  savings_investments_page.submit_more_than_ucd
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
  expect(confirmation_page.content).to have_application_complete
end

When("I grant help with fees by choosing delivery manager discretion") do
  confirmation_page.content.grant_hwf.click
  confirmation_page.content.override.delivery_manager_option.click
  confirmation_page.content.override.update_application_button.click
end

Then("I should see the applicant has been granted help with fees") do
  expect(confirmation_page.content).to have_granted_hwf
end

Given("I input low savings and no benefits but {int} income and then complete processing") do |int|
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(children_page.content).to have_header
  children_page.no_children
  expect(income_kind_applicant_page.content).to have_header
  income_kind_applicant_page.submit_wages
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes(int)
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
  expect(confirmation_page.content).to have_application_complete
end

Given("I input low savings with benefits but no paper evidence and then complete processing") do
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  stub_dwp_response_as_bad_request
  benefits_page.submit_benefits_yes
  expect(paper_evidence_page.content).to have_header
  paper_evidence_page.submit_evidence_no
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
  expect(confirmation_page.content).to have_application_complete
end

Given("I should see a confirmation letter") do
  expect(confirmation_page.content).to have_confirmation_letter
end

Given("I should not see a confirmation letter") do
  expect(confirmation_page.content).not_to have_confirmation_letter
end

Then("The results should show the application passed saving and investments by manager's discretion") do
  expect(confirmation_page.content.summary_list_row[0].text).to have_content 'Savings and investments'
  expect(confirmation_page.content.summary_list_row[0].text).to have_content '✓ Passed (by manager\'s decision)'
end

Then("The results should show the application passed income by manager's discretion") do
  expect(confirmation_page.content.summary_list_row[1].text).to have_content 'Income'
  expect(confirmation_page.content.summary_list_row[1].text).to have_content '✓ Passed (by manager\'s decision)'
end

Then("The results should show the application passed benefits by manager's discretion") do
  expect(confirmation_page.content.summary_list_row[1].text).to have_content 'Benefits'
  expect(confirmation_page.content.summary_list_row[1].text).to have_content '✓ Passed (by manager\'s decision)'
end

Then("I should see that the application fails because of saving and investments") do
  expect(confirmation_page.content).to have_ineligible
  expect(confirmation_page.content.summary_list_row[0].text).to have_content 'Savings and investments'
  expect(confirmation_page.content.summary_list_row[0].text).to have_content '✗ Failed'
end

Then("I should see that the application fails because of income") do
  expect(confirmation_page.content).to have_ineligible
  expect(confirmation_page.content.summary_list_row[1].text).to have_content 'Income'
  expect(confirmation_page.content.summary_list_row[1].text).to have_content '✗ Failed'
end

Then("I should see that the application fails because of benefits") do
  expect(confirmation_page.content).to have_ineligible
  expect(confirmation_page.content.summary_list_row[1].text).to have_content 'Benefits'
  expect(confirmation_page.content.summary_list_row[1].text).to have_content '✗ Failed'
end
