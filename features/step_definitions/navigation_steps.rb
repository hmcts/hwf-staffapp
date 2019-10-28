When("I click on feedback") do
  navigation_page.navigation_link.feedback.click
end

Then("I am taken to your feedback page") do
  expect(feedback_page.content).to have_user_feedback_header
  expect(current_path).to end_with '/feedback'
end

Then("I am taken to the feedback received page") do
  expect(feedback_page.content).to have_admin_feedback_header
  expect(current_path).to end_with '/feedback/display'
end

When("I click on sign out") do
  navigation_page.sign_out
end

Then("I am taken to the sign in page") do
  expect(current_path).to end_with '/users/sign_in'
end

When("I click on view profile") do
  navigation_page.navigation_link.view_profile.click
end

Then("I am taken to my details") do
  # steps need implementing - wip
end

When("I click on staff guides") do
  navigation_page.navigation_link.staff_guides.click
end

Then("I am taken to the guide page") do
  # steps need implementing - wip
end
