Given("I am signed in as admin") do
  admin_signed_in
  expect(admin_dashboard_page).to have_welcome_user
end

Then("I should see the reference number is not recognised") do
end

When("I click on view office") do
  admin_dashboard_page.view_office.click
end

Then("I am taken to the offices page") do
end

Then("I should see all the responses by type") do
end

Then("I should see checks by time of day") do
end

When("I click on court graphs under the header 5 day benefit check\/court graphs") do
end

Then("I am taken to reports and graphs") do
end
