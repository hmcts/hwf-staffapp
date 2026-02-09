Given("I have completed an application") do
  go_to_summary_page_low_savings
end

Given("I have completed an application with savings in pence") do
  go_to_summary_page_high_savings
end

Given('I have completed an application with paper evidence benefit check') do
  go_to_summary_page_low_savings_paper_evidence_benefit_check
end

Given("I am on the summary page") do
  expect(summary_page.content).to have_header
end

When("I successfully submit my application") do
  complete_processing
end

Then("I should be taken to the confirmation page") do
  expect(confirmation_page.content).to have_reference_number_is
  expect(confirmation_page.content).to have_eligible
end

When("I click on change benefits") do
  summary_page.content.summary_section[4].change_benefits.click
end

When("I change my answer to no") do
  benefits_page.submit_benefits_no
end

Then("I should see that my new answer is displayed in the benefit summary") do
  children_page.no_children
  income_kind_applicant_page.submit_wages
  incomes_page.submit_incomes_50_ucd
  declaration_page.sign_by_applicant
  expect(application_page.content.summary_section[4]).to have_answer_no
end

Then("I should see that the savings amount is rounded to the nearest pound") do
  expect(application_page.content.summary_section[3].text).to have_content 'Between £4,250 and £15,999 Yes Change Between £4,250 and £15,999 Savings and Investments total £10000 Change Savings and Investments total 66 years or older No Change 66 years or older'
end

Then("I should see the personal details") do
  expect(summary_page.content).to have_personal_details_header
  expect(summary_page.content.summary_section[1].list_row[0].text).to have_content 'Full name John Christopher Smith Change Full name'
  expect(summary_page.content.summary_section[1].list_row[1].text).to have_content 'Date of birth 10 February 1986 Change Date of birth'
  expect(summary_page.content.summary_section[1].list_row[2].text).to have_content 'Applicant over 16 Yes'
  expect(summary_page.content.summary_section[1].list_row[3].text).to have_content 'National Insurance number JR 05 40 08 D Change National Insurance number'
  expect(summary_page.content.summary_section[1].list_row[4].text).to have_content 'Status Single Change Status'
end

When('I click on change Date of Birth') do
  summary_page.content.summary_section[1].change_dob.click
end

Then('I should see that my new answer is displayed in the personal details summary') do
  expect(summary_page.content.summary_section[1].list_row[0].text).to have_content 'Full name Jean Jones Change Full name'
  expect(summary_page.content.summary_section[1].list_row[1].text).to have_content 'Date of birth 11 March 1983 Change Date of birth'
end

When('I click on change fee') do
  summary_page.content.summary_section[2].change_fee.click
end

Then('I should see that my new answer is displayed in the application details summary') do
  expect(summary_page.content.summary_section[2].list_row[0].text).to have_content "Fee £200.00 Change Fee"
end

Then('I should see that my new answer is displayed in the date received summary') do
  date_received = (Time.zone.today - 2.months).strftime("%-d %B %Y")
  date_fee_paid = (Time.zone.today - 4.months).strftime("%-d %B %Y")

  expect(summary_page.content.summary_section[0].list_row[0].text).to have_content "Date received #{date_received} Change Date received"
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_content "Refund request Yes Change Refund request"
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_content "Date fee paid #{date_fee_paid} Change Date fee paid"
end
