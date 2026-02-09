Given("I am on the benefits part of the application") do
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_with_no_answer_for_benefits
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
end

When("I answer yes to the benefits question") do
  expect(benefits_page.content).to have_benefit_question
  benefits_page.submit_benefits_yes
end

When("I answer no to the benefits question") do
  expect(benefits_page.content).to have_benefit_question
  benefits_page.submit_benefits_no
end

Then("I should be asked about paper evidence") do
  expect(paper_evidence_page.content).to have_header
end
