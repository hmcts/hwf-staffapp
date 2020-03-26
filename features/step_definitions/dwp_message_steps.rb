Then("I am on the DWP warning message page") do
  navigation_page.navigation_link.dwp_message.click
  expect(dwp_message_page.content).to have_header
  expect(dwp_message_page).to be_displayed
end

Then("I should see use the default DWP message is pre-selected") do
  expect(dwp_message_page.content).to have_selected
end

When("I check display DWP check is down message") do
  dwp_message_page.check_offline
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
  click_button 'Save changes'
  dwp_message_page.check_default
end
