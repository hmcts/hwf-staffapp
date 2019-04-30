When("I click on a processed application") do
  processed_applications_page.content.processed_application_link.click
end

Then("I should be taken to that application") do
  expect(current_path).to include '/processed_applications/1'
  expect(processed_applications_page.content).to have_processed_application_header
end

Then("I am taken to all processed applications") do
  expect(current_path).to include '/processed_applications'
  expect(processed_applications_page.content).to have_header
end
