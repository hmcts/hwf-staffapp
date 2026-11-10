Then("I am on the HMRC warning message page") do
  navigation_page.navigation_link.hmrc_message.click
  expect(hmrc_message_page.content).to have_header
  expect(hmrc_message_page).to be_displayed
end

Then("I should see use the default HMRC message is pre-selected") do
  expect(hmrc_message_page.content).to have_selected_default
end

When("I check display HMRC check is down message") do
  hmrc_message_page.content.offline_message.click
end

When("I check display HMRC check is working message") do
  hmrc_message_page.content.online_message.click
end

# Switches away from the default first, so going back to it is a real change
When("I check use the default HMRC check to display message") do
  hmrc_message_page.content.offline_message.click
  hmrc_message_page.content.save_changes.click
  hmrc_message_page.content.default_message.click
end

Then("I should see a message saying there are problems with the HMRC checker") do
  expect(dashboard_page).to have_hmrc_offline_banner
end

Then("I should see a message saying the HMRC checker is working") do
  expect(dashboard_page).to have_hmrc_online_banner
end

Then("I can view staff HMRC warning message page") do
  navigation_page.navigation_link.hmrc_message.click
  expect(hmrc_message_page.content).to have_header
end

Then("I should not be able to navigate to the HMRC warning message page") do
  expect(navigation_page.navigation_link).to have_no_hmrc_message
end
