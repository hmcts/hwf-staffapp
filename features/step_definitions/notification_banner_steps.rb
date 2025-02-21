Given("I am on the edit notification page") do
  navigation_page.navigation_link.edit_banner.click
  expect(edit_banner_page.content).to have_header
  expect(edit_banner_page).to be_displayed
end

When("I add a message") do
  expect(edit_banner_page.content).to have_input_box_label
  edit_banner_page.fill_in_editor with: 'This is a test staff notification message'
end

When("I check show on admin homepage") do
  edit_banner_page.content.show_message_checkbox.click
end

Then("I should see the notification on my homepage") do
  navigation_page.go_to_homepage
  expect(edit_banner_page.content.notification_banner.text).to eq 'This is a test staff notification message'
end

When("I uncheck show on admin homepage") do
  navigation_page.navigation_link.edit_banner.click
  edit_banner_page.content.show_message_checkbox.click
  click_on 'Save changes', visible: false
end

Then("I should not see the notification on my homepage") do
  navigation_page.go_to_homepage
  page.should have_no_content('This is a test staff notification message')
end
