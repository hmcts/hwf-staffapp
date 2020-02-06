When("I am signed in on the guide page") do
  sign_in_page.load_page
  sign_in_page.user_account
  navigation_page.navigation_link.staff_guides.click
  expect(guide_page.content).to have_guide_header
  expect(guide_page).to be_displayed
end

Then("I click on how to guide") do
  guide_page.content.how_to_guide.click
  expect(current_url).to end_with '/documents/2017/10/help-with-fees-how-to-guide.pdf'
end

Then("I am not within the network or connected to vpn") do
  expect(forbidden_page).to have_error_403
end

Then("I should see you are accessing the intranet from outside the MoJ network") do
  expect(forbidden_page).to have_header
end

When("I click on key control checks") do
  guide_page.content.key_control_checks.click
end

When("I should be taken to the key control checks page") do
  expect(current_url).to end_with '/documents/2017/10/help-with-fees-key-control-checks.pdf'
end

When("I click on staff guidance") do
  guide_page.content.staff_guidance.click
  expect(current_url).to end_with '/documents/2017/10/help-with-fees-policy-guide.pdf'
end

When("I click on process application") do
  guide_page.content.process_application.click
end

Then("I should be taken to the process application page") do
  expect(current_url).to end_with '/guide/process_application'
  expect(process_application_guide_page).to have_header
end

When("I click on evidance checks") do
  guide_page.content.evidence_checks.click
end

Then("I should be taken to the evidance checks page") do
  expect(current_url).to end_with '/guide/evidence_checks'
  expect(evidence_checks_guide_page).to have_header
end

When("I click on part-payments") do
  guide_page.content.part_payments.click
end

Then("I should be taken to the part-payments page") do
  expect(current_url).to end_with '/guide/part_payments'
  expect(part_payments_guide_page).to have_header
end

When("I click on appeals") do
  guide_page.content.appeals.click
end

Then("I should be taken to the appeals page") do
  expect(current_url).to end_with '/guide/appeals'
  expect(appeals_guide_page).to have_header
end

When("I click on fraud awareness") do
  guide_page.content.fraud_awareness.click
end

When("I click on suspected fraud") do
  guide_page.content.suspected_fraud.click
end

Then("I should be taken to the suspected fraud page") do
  expect(current_url).to end_with '/guide/suspected_fraud'
  expect(suspected_fraud_guide_page).to have_header
end
