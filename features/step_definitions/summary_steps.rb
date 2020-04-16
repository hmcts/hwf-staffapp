Given("I have completed an application") do
  summary_page.go_to_summary_page_low_savings
end

Given("I have completed an application with savings in pence") do
  summary_page.go_to_summary_page_high_savings
end

Given("I am on the summary page") do
  expect(current_path).to include 'summary'
  expect(summary_page.content).to have_header
end

When("I successfully submit my application") do
  complete_processing
end

Then("I should be taken to the confirmation page") do
  expect(current_path).to include 'confirmation'
  expect(confirmation_page.content).to have_eligible
end

When("I click on change benefits") do
  summary_page.content.summary_section[3].change_benefits.click
end

When("I change my answer to no") do
  benefits_page.submit_benefits_no
end

Then("I should see that my new answer is displayed in the benefit summary") do
  incomes_page.submit_incomes_no
  incomes_page.submit_incomes_50
  expect(application_page.content.summary_section[3]).to have_answer_no
end

Then("I should see that the savings amount is rounded to the nearest pound") do
  expect(application_page.content.summary_section[2].text).to eq 'Savings and investments Less than £3,000 No ChangeLess than £3,000 Savings amount £10000 ChangeSavings amount'
end

Then("I should see the personal details") do
  expect(summary_page.content.summary_section[0]).to have_personal_details_header
  expect(summary_page.content.summary_section[0].list_row[1].text).to eq 'Full name Mr John Christopher Smith ChangeFull name'
  expect(summary_page.content.summary_section[0].list_row[2].text).to eq 'Date of birth 10 February 1986 ChangeDate of birth'
  expect(summary_page.content.summary_section[0].list_row[3].text).to eq 'National Insurance number JR 05 40 08 D ChangeNational Insurance number'
  expect(summary_page.content.summary_section[0].list_row[4].text).to eq 'Status Single ChangeStatus'
end
