When("I click on a processed application") do
  processed_applications_page.content.click_link("#{reference_prefix}-000001")
end

Then("I should be taken to that application") do
  header_text = processed_applications_page.content.header.text
  expect(header_text).to eql "#{reference_prefix}-000001 - Processed application"
end

When("I click the Delete application details element") do
  processed_application_instance_page.content.delete_application_detail.click
end

And("I click Delete application button without providing a reason") do
  processed_application_instance_page.content.delete_application_button.click
end

Then("I should see an Enter the reason error") do
  expect(processed_application_instance_page.content).to have_enter_the_reason_error
end

And("I click Delete application button after providing a reason") do
  processed_application_instance_page.content.delete_application_textbox.set 'Reason'
  processed_application_instance_page.content.delete_application_button.click
end

Then("I should be redirected to processed applications") do
  expect(processed_applications_page).to be_displayed
end

And("I should see a message saying that the application has been deleted") do
  expect(processed_applications_page.content).to have_deleted_notice
end
