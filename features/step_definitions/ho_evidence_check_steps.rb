
When("a second application is processed with the same home office number") do
  dashboard_page.process_application
  personal_details_page.submit_all_personal_details_ho
  application_details_page.submit_as_refund_case
  savings_investments_page.submit_less_than
  benefits_page.submit_benefits_no
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_50
  complete_and_back_to_start
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
