Then("I am on the DWP warning message page") do
  navigation_page.go_to_dwp_message_page
  expect(current_path).to include '/dwp_warnings/edit'
  expect(dwp_message_page.content).to have_header
end

Then("I should see use the default DWP message is pre-selected") do
  expect(dwp_message_page.content).to have_selected
end

When("I check display DWP check is down message") do
  dwp_message_page.check_offline
end

When("I click on save changes") do
  dwp_message_page.save_changes
end

Then("I should see your changes have been saved message") do
  expect(dwp_message_page.content).to have_saved_alert
end

Then("I should see a message saying I am unable to check an applicants benefits") do
  expect(dashboard_page).to have_dwp_offline_banner
end

Then("I go to the homepage by clicking on Help with fees") do
  navigation_page.go_to_homepage
end

When("I check display DWP check is working message") do
  dwp_message_page.check_online
end

Then("I should see a message saying I can process benefits and income based applications") do
  expect(dashboard_page).to have_dwp_online_banner
end

When("I check use the default DWP check to display message") do
  dwp_message_page.check_offline
  dwp_message_page.save_changes
  dwp_message_page.check_default
end
