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
  expect(application_page.content.summary_section[2].text).to have_content 'Less than £3,000 No Change Less than £3,000 Savings amount £10000 Change Savings amount'
end

Then("I should see the personal details") do
  expect(summary_page.content).to have_personal_details_header
  expect(summary_page.content.summary_section[0].list_row[0].text).to have_content 'Full name John Christopher Smith Change Full name'
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_content 'Date of birth 10 February 1986 Change Date of birth'
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_content 'Applicant over 16 Yes'
  expect(summary_page.content.summary_section[0].list_row[3].text).to have_content 'National Insurance number JR 05 40 08 D Change National Insurance number'
  expect(summary_page.content.summary_section[0].list_row[4].text).to have_content 'Status Single Change Status'
end

When('I click on change Date of Birth') do
  summary_page.content.summary_section[0].change_dob.click
end

Then('I should see that my new answer is displayed in the personal details summary') do
  expect(summary_page.content.summary_section[0].list_row[0].text).to have_content 'Full name Mrs Jean Jones Change Full name'
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_content 'Date of birth 11 March 1983 Change Date of birth'
end

When('I click on change date received') do
  summary_page.content.summary_section[1].change_date_received.click
end

Then('I should see that my new answer is displayed in the application details summary') do
  date_of_death = (Time.zone.today - 1.month).strftime("%-d %B %Y")
  date_received = Time.zone.today.strftime("%-d %B %Y")
  date_fee_paid = Time.zone.yesterday.strftime("%-d %B %Y")

  expect(summary_page.content.summary_section[1].list_row[2].text).to have_content "Date received #{date_received} Change Date received"
  expect(summary_page.content.summary_section[1].list_row[5].text).to have_content "Name of the deceased John Doe Change Name of the deceased"
  expect(summary_page.content.summary_section[1].list_row[6].text).to have_content "Date of their death #{date_of_death} Change Date of their death"
  expect(summary_page.content.summary_section[1].list_row[7].text).to have_content "Refund request Yes Change Refund request"
  expect(summary_page.content.summary_section[1].list_row[8].text).to have_content "Date fee paid #{date_fee_paid} Change Date fee paid"
end
