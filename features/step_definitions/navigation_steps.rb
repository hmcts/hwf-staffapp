Then("I am taken to the sign in page") do
  expect(page).to have_current_path(%r{/users/sign_in})
end

Then("I can view my profile") do
  click_link 'View profile', visible: false
  expect(profile_page.content).to have_header
  expect(profile_page).to be_displayed
end

Then("I can give feedback") do
  click_link 'Feedback', visible: false
  expect(feedback_page.content).to have_user_feedback_header
  expect(current_url).to end_with '/feedback'
end

Then("I can view feedback received") do
  click_link 'Feedback', visible: false
  expect(feedback_page.content).to have_admin_feedback_header
  expect(current_url).to end_with '/feedback/display'
end

Then("I can view staff guides") do
  click_link 'Staff Guides', visible: false
  expect(guide_page.content).to have_guide_header
  expect(guide_page).to be_displayed
end

Then("I can view letter templates") do
  click_link 'Letter templates', visible: false
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
  click_link 'View office', visible: false
  expect(office_page.content).to have_header
  expect(office_page).to be_displayed
end

Then("I can view staff") do
  click_link 'View staff', visible: false
  expect(users_page.content).to have_header
  expect(users_page).to be_displayed
end

Then("I can edit banner") do
  click_link 'Edit banner', visible: false
  expect(edit_banner_page.content).to have_header
  expect(edit_banner_page).to be_displayed
end

Then("I can view staff DWP warning message page") do
  click_link 'DWP message', visible: false
  expect(dwp_message_page.content).to have_header
  expect(dwp_message_page).to be_displayed
end
