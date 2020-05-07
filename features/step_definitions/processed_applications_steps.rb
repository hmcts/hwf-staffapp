When("I click on a processed application") do
  processed_applications_page.content.click_link("#{reference_prefix}-000001")
end

Then("I should be taken to that application") do
  expect(current_path).to include '/processed_applications/1'
  header_text = processed_applications_page.content.header.text
  expect(header_text).to eql "#{reference_prefix}-000001 - Processed application"
end

Then("I am taken to all processed applications") do
  expect(current_path).to include '/processed_applications'
  expect(processed_applications_page.content).to have_header
end
