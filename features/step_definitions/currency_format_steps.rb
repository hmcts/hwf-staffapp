Given("there is a part payment application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_part_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page.content).to have_find_an_application_heading
end

Given("there is a part refund application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_part_refund, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page.content).to have_find_an_application_heading
end

Given("there is an eligible application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page.content).to have_find_an_application_heading
end

Given("I click next on the income result page") do
  expect(evidence_result_page.content).to have_header
  evidence_result_page.click_next
end

When("I click complete processing") do
  expect(summary_page.content).to have_header
  complete_processing
end

Then("I should be on the evidence confirmation page") do
  expect(evidence_confirmation_page.content).to have_confirmation_panel
end

Then("I should be on the paper application confirmation page") do
  expect(confirmation_page.content).to have_reference_number_is
end

Then("I should see amount to pay is an integer amount") do
  expect(confirmation_page.content.fee_to_pay.text).to have_no_text '.00'
end

Then("I should see total monthly income is an integer amount") do
  expect(confirmation_page.content.total_income.text).to have_no_text '.00'
end

Then("I should see maximum amount of savings and investments allowed is an integer amount") do
  expect(confirmation_page.content.max_savings.text).to have_no_text '.00'
end

Then("I should see total savings is an integer amount") do
  expect(confirmation_page.content.total_savings.text).to have_no_text '.00'
end

Then("I should see that all currency amounts are integers") do
  expect(confirmation_page.content.part_payment_sentence.text).to have_no_text '.00'
end

Given("I have completed a part payment paper application") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_2000
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(children_page.content).to have_header
  children_page.no_children
  expect(income_kind_applicant_page.content).to have_header
  income_kind_applicant_page.submit_wages
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_4000_ucd
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
  expect(confirmation_page.content).to have_part_payment
end

When("I have completed a part refund paper application") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_2000
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(children_page.content).to have_header
  children_page.no_children
  expect(income_kind_applicant_page.content).to have_header
  income_kind_applicant_page.submit_wages
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_4000_ucd
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
  expect(confirmation_page.content).to have_part_payment
end
