Given("I have processed an application that is a part payment") do
  part_payment_application
end

And("the payment is ready to process") do
  click_link "#{reference_prefix}-000001"
  expect(page).to have_current_path(%r{/part_payments})
  click_on 'Start now', visible: false
  expect(page).to have_current_path(%r{/accuracy})
  part_payment_page.ready_to_process_payment
end

And("the payment is not ready to process") do
  click_link "#{reference_prefix}-000001"
  expect(part_payment_page).to have_current_path(%r{/part_payments})
  click_on 'Start now', visible: false
  expect(part_payment_page).to have_current_path(%r{/accuracy})
  part_payment_page.not_ready_to_process_payment
end

And("I open the processed part payment application") do
  click_link "#{reference_prefix}-000001", visible: false
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
