Given("I am on your feedback page") do
  navigation_page.navigation_link.feedback.click
  expect(current_path).to end_with '/feedback'
end

When("I successfully submit my feedback") do
  feedback_page.submit_new_feedback
end

Then("I should be taken to my dashboard") do
  expect(current_path).to end_with '/'
end

Then("I should see your feedback has been recorded notification") do
  expect(feedback_page.content).to have_notice
end