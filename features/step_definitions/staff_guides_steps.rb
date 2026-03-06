When("I am signed in on the guide page") do
  sign_in_page.load_page
  sign_in_page.user_account
  navigation_page.navigation_link.staff_guides.click
  expect(guide_page.content).to have_guide_header
  expect(guide_page).to be_displayed
end

Then("I can view How to Guide") do
  expect(guide_page.content.how_to_guide['href']).to include 'sourcedoc=%7B5D999F01-6E39-4EB6-8703-E3E4A0262580%7D'
end

Then("I can view the training course") do
  expect(guide_page.content.training_course['href']).to include 'sourcedoc=%7BB3128FFC-3EF6-4648-B2BB-8A3D8A29E9BA%7D'
end

When("I can view key control checks guide") do
  expect(guide_page.content.key_control_checks['href']).to include 'sourcedoc=%7BF13EB074-F2F7-4349-BC0A-BA191503BBE9%7D'
end

When("I can view staff guidance") do
  expect(guide_page.content.staff_guidance['href']).to include 'sourcedoc=%7BDD4BE471-9B43-43D4-9E71-0FB28A9B41EE%7D'
end

Then("I can view old process application") do
  expect(guide_page.content.old_process_application['href']).to end_with '/documents/2021/11/processing-a-help-with-fees-application.docx'
end

Then("I can view new process application") do
  expect(guide_page.content.new_process_application['href']).to include 'sourcedoc=%7BB62AF5DB-DF50-4415-A261-A4598E61B298%7D'
end

Then("I can view new online process application") do
  expect(guide_page.content.new_online_process_application['href']).to include 'sourcedoc=%7B1ADE6338-5A41-4D11-8047-ACBB1A070C19%7D'
end

Then("I can view old evidence checks") do
  expect(guide_page.content.old_evidence_checks['href']).to end_with '/documents/2020/12/help-with-fees-processing-evidence-job-card.pdf'
end

Then("I can view new evidence checks") do
  expect(guide_page.content.new_evidence_checks['href']).to include 'sourcedoc=%7B40446293-A8A9-4003-B09E-F228F727A441%7D'
end

Then("I can view part payments") do
  expect(guide_page.content.part_payments['href']).to include 'sourcedoc=%7BA5D5C042-C211-45A6-B1C5-22275AC6E0C5%7D'
end

Then("I can view fraud awareness guide") do
  expect(guide_page.content.fraud_awareness['href']).to include 'sourcedoc=%7B03E83158-CD55-45F0-9D99-FC7B02BF2343%7D'
end

Then("I can view RRDS") do
  expect(guide_page.content.rrds['href']).to include 'sourcedoc=%7B34D2BF32-AEB1-41D7-BF74-9C76A6E8042B%7D'
end

Then("I can view HMRC Datashare") do
  expect(guide_page.content.hmrc_datashare['href']).to include 'sourcedoc=%7BD130FF65-E19C-4A4D-9F02-5E2FF579B229%7D'
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
