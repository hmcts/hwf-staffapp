Given("I am signed in as a user that has processed an application") do
  start_application
  expect(dashboard_page).to have_current_path('/')
  eligable_application
end

Given("I am signed in as a user that has processed multiple applications") do
  start_application
  expect(dashboard_page).to have_current_path('/')
  multiple_applications
  click_on "Help with fees"
  expect(dashboard_page).to have_welcome_user
end

When("I click on next without making a selection") do
  click_button('Next')
end

Then("I should see select from one of the options error message") do
  expect(base_page.content).to have_select_from_list_error
end

When("I click on save changes") do
  click_on 'Save changes', visible: false
end

Then("I should see your changes have been saved message") do
  expect(base_page.content).to have_saved_alert
end

Given("I have evidence check application") do
  waiting_evidence_application_ni
end
