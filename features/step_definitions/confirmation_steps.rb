And("I have processed an application") do
  start_application
  dashboard_page.process_application

  expect(personal_details_page).to have_current_path(%r{/personal_informations})
  personal_details_page.submit_all_personal_details_ni

  expect(application_details_page).to have_current_path(%r{/details})
  application_details_page.submit_fee_600

  expect(savings_investments_page).to have_current_path(%r{/savings_investments})
  savings_investments_page.submit_less_than

  expect(benefits_page).to have_current_path(%r{/benefits})
  benefits_page.submit_benefits_yes

  expect(paper_evidence_page).to have_current_path(%r{/paper_evidence})
  paper_evidence_page.submit_evidence_yes

  expect(summary_page).to have_current_path(%r{/summary})
  complete_processing
end

Given("I am on the confirmation page") do
  expect(confirmation_page).to have_current_path(%r{/confirmation})
  expect(confirmation_page.content).to have_eligible
end

When("I click on back to start") do
  click_on 'Back to start', visible: false
end

Then("I should be taken back to my dashboard") do
  expect(page).to have_text 'Process an online application'
  expect(page).to have_current_path('/')
end

Then("I should see my processed application in your last applications") do
  expect(dashboard_page.content).to have_processed_applications
  expect(dashboard_page.content).to have_last_application
end

Then("I should see that the applicant is eligible for help with fees") do
  expect(confirmation_page.content).to have_eligible
end

Then("I should see a help with fees reference number") do
  expect(confirmation_page.content).to have_reference_number_is
  reference_number = "#{reference_prefix}-000001"
  expect(confirmation_page.content.reference_number.text).to eql(reference_number)
end

Then("I should see the next steps") do
  expect(confirmation_page.content).to have_next_steps_steps
  expect(confirmation_page.content).to have_write_ref
  expect(confirmation_page.content).to have_copy_ref
  expect(confirmation_page.content).to have_can_be_issued
end

When("I can view the guides in a new window") do
  expect(confirmation_page.content.see_guides['href']).to have_text '/guide'
  expect(confirmation_page.content.see_guides['target']).to eq 'blank'
end
