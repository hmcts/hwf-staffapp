Given("I have processed an application that is a refund") do
  sign_in_page.load_page
  sign_in_page.user_account
  part_payment_application
end

But("the applicant must pay towards the fee") do
  expect(confirmation_page.content.outcome_header.text).to have_text 'The applicant must pay £40 towards the fee'
  click_on 'Back to start', visible: false
end

And("the payment is ready to process") do
  click_link "#{reference_prefix}-000001"
  click_on 'Start now', visible: false
  part_payment_page.ready_to_process_payment
end

And("the payment is not ready to process") do
  click_link "#{reference_prefix}-000001"
  click_on 'Start now', visible: false
  part_payment_page.not_ready_to_process_payment
end

And("I open the processed part payment application") do
  click_link "#{reference_prefix}-000001"
end

Then("I can see that the applicant has paid £40 towards the fee") do
  expect(processed_applications_page.content.result.text).to have_text 'The applicant has paid £40 towards the fee'
end

Then("I should see my reason on the part payments summary page") do
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_text 'Part payment No Change Part payment'
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_text 'Reason No signature on cheque Change Reason'
end

Then("I can see that the applicant needs to make a new application") do
  expect(processed_applications_page.content.result.text).to have_text 'The applicant will need to make a new application'
end

Then("processing is complete I should see a letter template") do
  click_on 'Complete processing', visible: false
  expect(part_payment_page.content).to have_evidence_confirmation_letter
  click_on 'Back to start', visible: false
  expect(current_url).to end_with '/'
end
