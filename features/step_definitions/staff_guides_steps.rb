When("I am signed in on the guide page") do
  sign_in_page.load_page
  sign_in_page.user_account
  navigation_page.navigation_link.staff_guides.click
  expect(guide_page.content).to have_guide_header
  expect(guide_page).to be_displayed
end

Then("I can view How to Guide") do
  expect(guide_page.content.how_to_guide['href']).to end_with '/documents/2017/10/help-with-fees-how-to-guide.pdf'
end

Then("I can view the training course") do
  expect(guide_page.content.training_course['href']).to eq 'https://mydevelopment.org.uk/course/view.php?id=9824'
end

When("I can view key control checks guide") do
  expect(guide_page.content.key_control_checks['href']).to end_with '/documents/2017/02/help-with-fees-kccs.docx'
end

When("I can view staff guidance") do
  expect(guide_page.content.staff_guidance['href']).to end_with '/my-work/help-with-fees/staff-guidance/'
end

Then("I can view old process application") do
  expect(guide_page.content.old_process_application['href']).to end_with '/documents/2021/11/processing-a-help-with-fees-application.docx'
end

Then("I can view new process application") do
  expect(guide_page.content.new_process_application['href']).to end_with '/documents/2023/11/processing-a-help-with-fees-application-post-27th-november-23.docx'
end

Then("I can view old evidence checks") do
  expect(guide_page.content.old_evidence_checks['href']).to end_with '/documents/2020/12/help-with-fees-processing-evidence-job-card.pdf'
end

Then("I can view new evidence checks") do
  expect(guide_page.content.new_evidence_checks['href']).to end_with '/documents/2023/11/processing-evidence-post-27th-november-23.docx'
end

Then("I can view part payments") do
  expect(guide_page.content.part_payments['href']).to end_with '/documents/2020/12/help-with-fees-processing-a-part-payment-job-card.pdf'
end

Then("I can view fraud awareness guide") do
  expect(guide_page.content.fraud_awareness['href']).to end_with '/documents/2018/05/help-with-fees-fraud-awareness-pdf.pdf'
end

Then("I can view RRDS") do
  expect(guide_page.content.rrds['href']).to end_with '/publications/record-retention-and-disposition-schedules'
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
