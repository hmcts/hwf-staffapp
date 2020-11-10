Then("I should see the status of the DWP connection") do
  expect(dashboard_page).to have_css('.dwp-tag')
end

When("I search for an application using valid reference number") do
  dashboard_page.search_valid_reference
end

When("I search for an application using invalid reference number") do
  dashboard_page.search_invalid_reference
end

When("I look up a valid hwf reference") do
  dashboard_page.look_up_valid_reference
end

When("I look up a invalid hwf reference") do
  dashboard_page.look_up_invalid_reference
end

When("I click on processed applications") do
  dashboard_page.content.processed_applications.click
  expect(processed_applications_page).to have_current_path('/processed_applications')
end
