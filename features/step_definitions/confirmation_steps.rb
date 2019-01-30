And("I have processed an application") do
  go_to_confirmation_page
end

Given("I am on the confirmation page") do
  expect(current_path).to include 'confirmation'
  expect(confirmation_page.content).to have_eligible
end

When("I click on back to start") do
  confirmation_page.back_to_start
end

Then("I should be taken back to my dashboard") do
  expect(current_path).to eq '/'
end

Then("I should see my processed application in your last applications") do
  expect(dashboard_page.content).to have_processed_applications
  expect(dashboard_page.content).to have_last_application
end
