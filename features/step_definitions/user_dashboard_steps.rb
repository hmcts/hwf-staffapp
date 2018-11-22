Given("I am signed in as a user") do
  user_signed_in
  expect(user_dashboard_page).to have_welcome_user
end

When("I click on view profile") do
  user_dashboard_page.view_profile.click
end

Then("I am taken to my details") do
  binding.pry
end

When("I click on staff guides") do
  user_dashboard_page.staff_guides.click
end

Then("I am taken to the guide page") do
  binding.pry
end

Then("I should see the status of the DWP connection") do
  expect(user_dashboard_page.content).to have_dwp_restored
end

When("I search for an application using valid reference number") do
  binding.pry
  user_dashboard_page.search_valid_reference
end

Then("I am taken to ....") do
  binding.pry
end

When("I search for an application using invalid reference number") do
  binding.pry
  user_dashboard_page.search_invalid_reference
end

Then("I should see the reference number is not recognised error message") do
  binding.pry
end

When("I start a new application") do
  binding.pry
end

Then("I am taken to the applicants personal details page") do
  binding.pry
end

When("I look up a valid hwf reference") do
  user_dashboard_page.look_up_valid_reference
end

When("I look up a invalid hwf reference") do
  user_dashboard_page.look_up_invalid_reference
end

When("I click on the reference number of an application that is waiting for evidence") do
  binding.pry
end

Then("I am taken to the application waiting for evidence") do
  binding.pry
end

When("I click on the reference number of an application that is waiting for part-payment") do
  binding.pry
end

Then("I am taken to the application waiting for part-payment") do
  binding.pry
end

When("I click on the reference number of one of my last applications") do
  binding.pry
end

Then("I am taken to that application") do
  binding.pry
end

When("I click on processed applications") do
  user_dashboard_page.content.processed_applications.click
end

Then("I am taken to all processed applicantions") do
  binding.pry
end

When("I click on deleted applications") do
  binding.pry
end

Then("I am taken to all deleted applicantions") do
  binding.pry
end