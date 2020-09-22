
When("a second application is processed with the same home office number") do
  dashboard_page.process_application
  expect(personal_details_page).to have_current_path(%r{/personal_informations})
  personal_details_page.submit_all_personal_details_ho
  expect(application_details_page).to have_current_path(%r{/details})
  application_details_page.submit_as_refund_case
  expect(savings_investments_page).to have_current_path(%r{/savings_investments})
  savings_investments_page.submit_less_than
  expect(benefits_page).to have_current_path(%r{/benefits})
  benefits_page.submit_benefits_no
  expect(incomes_page).to have_current_path(%r{/incomes})
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_50
  expect(page).to have_current_path(%r{/summary})
  complete_and_back_to_start
  expect(page).to have_current_path('/')
end

Then("the first application will be processed") do
  expect(ho_evidence_check_page.content.your_last_application[2].text).to have_content 'processed Mr John Christopher Smith'
end

But("the second application will require evidence") do
  expect(ho_evidence_check_page.content.your_last_application[1].text).to have_content 'waiting_for_evidence Mr John Christopher Smith'
end

Given("and I process applications where the applicant has a home office number") do
  ho_applicant
  refund_application
end
