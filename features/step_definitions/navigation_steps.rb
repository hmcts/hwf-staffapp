Then("I can view my profile") do
  navigation_page.navigation_link.view_profile.click
  expect(profile_page.content).to have_header
end

Then("I can view feedback received") do
  navigation_page.navigation_link.feedback.click
  expect(feedback_page.content).to have_admin_feedback_header
end

Then("I can give feedback") do
  click_link 'Tell us what you think', visible: false
  expect(feedback_page.content).to have_user_feedback_header
end

Then("I can view staff guides") do
  navigation_page.navigation_link.staff_guides.click
  expect(guide_page.content).to have_guide_header
end

Then("I can view letter templates") do
  navigation_page.navigation_link.letter_templates.click
  expect(letter_template_page.content).to have_header
end

Then("I can view office details") do
  navigation_page.navigation_link.view_office.click
  expect(office_page.content).to have_header
end

Then("I can view staff") do
  navigation_page.navigation_link.view_staff.click
  expect(staff_page.content).to have_header
end

Then("I can edit banner") do
  navigation_page.navigation_link.edit_banner.click
  expect(edit_banner_page.content).to have_header
end

Then("I can view staff DWP warning message page") do
  navigation_page.navigation_link.dwp_message.click
  expect(dwp_message_page.content).to have_header
end
