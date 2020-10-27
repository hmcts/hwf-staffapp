Given("there is a part payment application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_part_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_current_path('/')
end

Given("there is a part refund application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_part_refund, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_current_path('/')
end

Given("there is an eligible application waiting for evidence") do
  user = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission, :waiting_for_evidence_state, ni_number: 'AB123456D', office: user.office, user: user)

  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_current_path('/')
end

Given("I click next on the income result page") do
  expect(evidence_result_page).to have_current_path(%r{/evidence/[0-9]+/result})
  evidence_result_page.click_next
end

When("I click complete processing") do
  expect(evidence_result_page).to have_current_path(%r{/evidence/[0-9]+/summary})
  complete_processing
end

Then("I should be on the evidence confirmation page") do
  expect(evidence_confirmation_page).to have_current_path(%r{/evidence/[0-9]+/confirmation})
end

Then("I should be on the paper application confirmation page") do
  expect(confirmation_page).to have_current_path(%r{/applications/[0-9]+/paper/confirmation})
end

Then("I should see amount to pay is an integer amount") do
  expect(confirmation_page.content.fee_to_pay.text).not_to have_text '.00'
end

Then("I should see total monthly income is an integer amount") do
  expect(confirmation_page.content.total_income.text).not_to have_text '.00'
end

Then("I should see maximum amount of savings and investments allowed is an integer amount") do
  expect(confirmation_page.content.max_savings.text).not_to have_text '.00'
end

Then("I should see total savings is an integer amount") do
  expect(confirmation_page.content.total_savings.text).not_to have_text '.00'
end

Then("I should see that all currency amounts are integers") do
  expect(confirmation_page.content.part_payment_sentence.text).not_to have_text '.00'
end

Given("I have completed a part payment paper application") do
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.process_application
  expect(personal_details_page).to have_current_path(/personal_informations/)
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page).to have_current_path(/details/)
  application_details_page.submit_fee_600
  expect(savings_investments_page).to have_current_path(/savings_investments/)
  savings_investments_page.submit_less_than
  expect(benefits_page).to have_current_path(/benefits/)
  benefits_page.submit_benefits_no
  expect(incomes_page).to have_current_path(/incomes/)
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_1200
  expect(summary_page).to have_current_path(/summary/)
  complete_processing
  expect(confirmation_page.content).to have_part_payment
end

When("I have completed a part refund paper application") do
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
  complete_processing
  expect(confirmation_page.content).to have_part_payment
end
