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

Then("I can view the Job Cards") do
  expect(guide_page.content.job_cards['href']).to end_with '/about-hmcts/my-work/help-with-fees/job-cards/'
end

Then("I can view the training course") do
  expect(guide_page.content.training_course['href']).to eq 'https://mydevelopment.org.uk/course/view.php?id=9824'
end

When("I can view key control checks guide") do
  expect(guide_page.content.key_control_checks['href']).to end_with '/documents/2017/02/help-with-fees-kccs.docx'
end

When("I can view staff guidance") do
  expect(guide_page.content.staff_guidance['href']).to end_with '/documents/2017/10/help-with-fees-policy-guide.pdf'
end

When("I click on process application") do
  guide_page.content.process_application.click
end

Then("I should be taken to the process application guide") do
  expect(process_application_guide_page).to have_header
end

When("I click on evidence checks") do
  guide_page.content.evidence_checks.click
end

Then("I should be taken to the evidence checks guide") do
  expect(evidence_checks_guide_page).to have_header
end

When("I click on part-payments") do
  guide_page.content.part_payments.click
end

Then("I should be taken to the part-payments guide") do
  expect(part_payments_guide_page).to have_header
end

When("I click on appeals") do
  guide_page.content.appeals.click
end

Then("I should be taken to the appeals guide") do
  expect(appeals_guide_page).to have_header
end

Then("I can view fraud awareness guide") do
  expect(guide_page.content.fraud_awareness['href']).to end_with '/documents/2018/05/help-with-fees-fraud-awareness-pdf.pdf'
end

When("I click on suspected fraud") do
  guide_page.content.suspected_fraud.click
end

Then("I should be taken to the suspected fraud guide") do
  expect(suspected_fraud_guide_page).to have_header
end

Then("I can view Staff guides link on footer") do
  expect(sign_in_page.footer).to have_see_the_guides
end

When("I click on Staff guides link") do
  sign_in_page.footer.see_the_guides.click
end

Then("I should be taken to the guide page") do
  guide_page.load_page
  expect(guide_page).to be_displayed
  expect(guide_page.content).to have_guide_header
end

Then("I will see a Job Cards link") do
  expect(guide_page.content).to have_job_cards
  expect(guide_page.content.job_cards['href']).to eql 'https://intranet.justice.gov.uk/about-hmcts/my-work/help-with-fees/job-cards/'
end

Then("I can view guides by clicking on the link in the footer") do
  expect(page).to have_xpath('.//a[@href="/guide"][@target="blank"][contains(.,"See the guides")]')
  visit '/guide'
  expect(page).to have_text 'How to process an application, deal with evidence checks, part-payments, appeals, and fraud.'
end

When("I click on the accessibility link in the footer") do
  sign_in_page.footer.accessibility_statement_link.click
end

Then("I am on the accessibility statement page") do
  expect(page).to have_content 'Accessibility statement for Help with Fees (staff service)'
end
