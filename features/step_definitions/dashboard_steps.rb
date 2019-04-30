When("I click on view profile") do
  dashboard_page.view_profile.click
end

Then("I am taken to my details") do
  # steps need implementing - wip
end

When("I click on staff guides") do
  dashboard_page.staff_guides.click
end

Then("I am taken to the guide page") do
  # steps need implementing - wip
end

Then("I should see the status of the DWP connection") do
  expect(dashboard_page.content).to have_dwp_restored
end

When("I search for an application using valid reference number") do
  # steps need implementing - wip
  dashboard_page.search_valid_reference
end

When("I search for an application using invalid reference number") do
  # steps need implementing - wip
  dashboard_page.search_invalid_reference
end

Then("I should see the reference number is not recognised error message") do
  # steps need implementing - wip
end

When("I start a new application") do
  dashboard_page.process_application
end

Then("I am taken to the applicants personal details page") do
  # steps need implementing - wip
end

When("I look up a valid hwf reference") do
  dashboard_page.look_up_valid_reference
end

When("I look up a invalid hwf reference") do
  dashboard_page.look_up_invalid_reference
end

When("I click on processed applications") do
  dashboard_page.content.processed_applications.click
end

Then("I am taken to all processed applicantions") do
  expect(current_path).to include '/processed_applications'
  expect(processed_applications_page.content).to have_header
end
