
When("a second application is processed with the same home office number") do
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ho
  expect(application_details_page.content).to have_header
  application_details_page.submit_as_refund_case
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(children_page.content).to have_header
  children_page.no_children
  expect(income_kind_applicant_page.content).to have_header
  income_kind_applicant_page.submit_wages
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_50_ucd
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_and_back_to_start
  expect(dashboard_page.content).to have_find_an_application_heading
end

Then("the first application will be waiting") do
  expect(ho_evidence_check_page.content.your_last_application[2].text).to have_content 'waiting_for_evidence Mr John Christopher Smith'
end

But("the second application will require evidence") do
  expect(ho_evidence_check_page.content.your_last_application[1].text).to have_content 'waiting_for_evidence John Christopher Smith'
end

Given("I process applications with waiting evidence check where the applicant has a home office number") do
  user = FactoryBot.create(:user)
  ho_applicant
  refund_application_with_waiting_evidence(user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page.content).to have_find_an_application_heading
end
