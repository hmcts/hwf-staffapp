When("I am signed in on the guide page") do
  sign_in_page.load_page
  sign_in_page.user_account
  navigation_page.navigation_link.staff_guides.click
  expect(guide_page.content).to have_guide_header
  expect(guide_page).to be_displayed
end

Then("I can view how to guide") do
  expect(guide_page.content.how_to_guide['href']).to end_with '/documents/2017/10/help-with-fees-how-to-guide.pdf'
end

When("I can view key control checks guide") do
  expect(guide_page.content.key_control_checks['href']).to end_with '/documents/2017/10/help-with-fees-key-control-checks.pdf'
end

When("I can view staff guidance") do
  expect(guide_page.content.staff_guidance['href']).to end_with '/documents/2017/10/help-with-fees-policy-guide.pdf'
end

When("I can view the COVID 19 guidance") do
  expect(guide_page.content.covid_guidance['href']).to end_with '/documents/2020/04/covid-19-guidance-for-help-with-fees-process.pdf'
end

When("I click on process application") do
  guide_page.content.process_application.click
end

Then("I should be taken to the process application guide") do
  expect(current_url).to end_with '/guide/process_application'
  expect(process_application_guide_page).to have_header
end

When("I click on evidance checks") do
  guide_page.content.evidence_checks.click
end

Then("I should be taken to the evidance checks guide") do
  expect(current_url).to end_with '/guide/evidence_checks'
  expect(evidence_checks_guide_page).to have_header
end

When("I click on part-payments") do
  guide_page.content.part_payments.click
end

Then("I should be taken to the part-payments guide") do
  expect(current_url).to end_with '/guide/part_payments'
  expect(part_payments_guide_page).to have_header
end

When("I click on appeals") do
  guide_page.content.appeals.click
end

Then("I should be taken to the appeals guide") do
  expect(current_url).to end_with '/guide/appeals'
  expect(appeals_guide_page).to have_header
end

Then("I can view fraud awareness guide") do
  expect(guide_page.content.fraud_awareness['href']).to end_with '/documents/2018/05/help-with-fees-fraud-awareness-pdf.pdf'
end

When("I click on suspected fraud") do
  guide_page.content.suspected_fraud.click
end

Then("I should be taken to the suspected fraud guide") do
  expect(current_url).to end_with '/guide/suspected_fraud'
  expect(suspected_fraud_guide_page).to have_header
end

When("I click on see the guides in the footer") do
  click_link('See the guides')
end

Then("I should be taken to the guide page") do
  expect(current_url).to end_with '/guide'
end

Then("I should not see you need to sign in error message") do
  expect(sign_in_page.content).to have_no_sign_in_alert
end
