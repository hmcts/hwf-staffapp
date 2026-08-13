When("I visit the dashboard page") do
  expect(dashboard_page).to be_displayed
end

When("I should be on the generate reports page") do
  expect(reports_page).to be_displayed
end

When("I process the online application") do
  reference = @online_application.reference
  dashboard_page.look_up_reference(reference)
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
end

And("I take a screenshot of the page") do
  page.save_screenshot("../accessibility/screenshot-#{Time.now.to_i}.png")
end