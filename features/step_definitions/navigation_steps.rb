Then("I am taken to the sign in page") do
  expect(current_path).to end_with '/users/sign_in'
end

Then("I can view my profile") do
  navigation_page.navigation_link.view_profile.click
  expect(profile_page.content).to have_header
  expect(profile_page).to be_displayed
end

Then("I can give feedback") do
  navigation_page.navigation_link.feedback.click
  expect(feedback_page.content).to have_user_feedback_header
  expect(current_url).to end_with '/feedback'
end

Then("I can view feedback received") do
  navigation_page.navigation_link.feedback.click
  expect(feedback_page.content).to have_admin_feedback_header
  expect(current_url).to end_with '/feedback/display'
end

Then("I can view staff guides") do
  navigation_page.navigation_link.staff_guides.click
  expect(guide_page.content).to have_guide_header
  expect(guide_page).to be_displayed
end

Then("I can view letter templates") do
  navigation_page.navigation_link.letter_templates.click
  expect(letter_template_page.content).to have_header
  expect(letter_template_page).to be_displayed
end

Then("I should not be able to navigate to office details") do
  expect(navigation_page.navigation_link).to have_no_view_office
end

Then("I should not be able to navigate to edit banner") do
  expect(navigation_page.navigation_link).to have_no_edit_banner
end

Then("I should not be able to navigate to the staff page") do
  expect(navigation_page.navigation_link).to have_no_view_staff
end

Then("I should not be able to navigate to the DWP warning message page") do
  expect(navigation_page.navigation_link).to have_no_dwp_message
end

Then("I can view office details") do
  navigation_page.navigation_link.view_office.click
  expect(office_page.content).to have_header
  expect(office_page).to be_displayed
end

Then("I can view staff") do
  navigation_page.navigation_link.view_staff.click
  expect(users_page.content).to have_header
  expect(users_page).to be_displayed
end

Then("I can edit banner") do
  navigation_page.navigation_link.edit_banner.click
  expect(edit_banner_page.content).to have_header
  expect(edit_banner_page).to be_displayed
end

Then("I can view staff DWP warning message page") do
  navigation_page.navigation_link.dwp_message.click
  expect(dwp_message_page.content).to have_header
  expect(dwp_message_page).to be_displayed
end
