Given("I have processed an application that is a part payment") do
  user = FactoryBot.create(:user)
  part_payment_application(user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_welcome_user
end

And("the payment is ready to process") do
  click_reference_link
  expect(part_payment_page).to have_current_path(%r{/part_payments})
  click_on 'Start now', visible: false
  expect(page).to have_current_path(%r{/accuracy})
  part_payment_page.ready_to_process_payment
end

And("the payment is not ready to process") do
  click_reference_link
  expect(part_payment_page).to have_current_path(%r{/part_payments})
  click_on 'Start now', visible: false
  expect(part_payment_page).to have_current_path(%r{/accuracy})
  part_payment_page.not_ready_to_process_payment
end

And("I open the processed part payment application") do
  click_reference_link
end

Then("I can see that the applicant has paid £40 towards the fee") do
  expect(page).to have_current_path(%r{/processed_applications/})
  expect(processed_applications_page.content.result.text).to have_text 'The applicant has paid £40 towards the fee'
end

Then("I should see my reason on the part payments summary page") do
  expect(page).to have_current_path(%r{/summary})
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_text 'Part payment No Change Part payment'
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_text 'Reason No signature on cheque Change Reason'
end

Then("I can see that the applicant needs to make a new application") do
  expect(processed_applications_page.content.result.text).to have_text 'The applicant will need to make a new application'
end

Then("processing is complete I should see a letter template") do
  complete_processing
  expect(part_payment_page.content).to have_evidence_confirmation_letter
  click_on 'Back to start', visible: false
  expect(page).to have_current_path('/')
end

When("I go to the part payment application") do
  click_reference_link
  expect(part_payment_page).to have_current_path(/part_payments/)
end

And("I click on What to do when a part payment has not been received") do
  part_payment_page.content.not_received.click
  expect(part_payment_page.content).to have_return_application_button
end

And("I click Return application") do
  part_payment_page.content.return_application_button.click
  expect(part_payment_return_letter_page).to have_current_path(/return_letter$/)
end

Then("I should see a Processing complete banner") do
  expect(part_payment_return_letter_page.content).to have_processing_complete_banner
end

And("I should see a letter template for no received part-payment") do
  expect(part_payment_return_letter_page.content.letter_template).to have_explanation
end

And("I should see a Back to start button") do
  expect(part_payment_return_letter_page.content).to have_back_to_start
end
