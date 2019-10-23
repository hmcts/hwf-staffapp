When("I click on feedback") do
  navigation_page.navigation_link.feedback.click
end

Then("I am taken to your feedback page") do
  expect(feedback_page.content).to have_header
  expect(current_path).to end_with '/feedback'
end

Then("I am taken to the feedback received page") do
  expect(feedback_received_page.content).to have_header
  expect(current_path).to end_with '/feedback/display'
end
