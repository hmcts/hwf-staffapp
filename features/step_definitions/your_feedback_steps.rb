And("I am on your feedback page") do
  navigation_page.navigation_link.feedback.click
  expect(feedback_page.content).to have_user_feedback_header
  expect(feedback_page.content).to have_welcome_feedback
end

When("I successfully submit my feedback") do
  feedback_page.submit_new_feedback
end

Then("I should be taken to my dashboard") do
  expect(dashboard_page.content).to have_find_an_application_heading
end

Then("I should see your feedback has been recorded notification") do
  expect(feedback_page.content).to have_notice
end

Then("I can email if I have an urgent question or something isn't working") do
  expect(feedback_page.content).to have_email_us
  expect(feedback_page.content.email['href']).to eq 'mailto:helpwithfees.feedback@digital.justice.gov.uk'
end

When("I click on Send feedback") do
  feedback_page.content.send_feedback_button.click
end

Then("I should see an error summary message") do
  expect(feedback_page.content).to have_error_summary
  expect(feedback_page.content).to have_error_summary_title
  expect(feedback_page.content).to have_error_summary_list
end

And("I should see a rating error") do
  expect(feedback_page.content).to have_rating_error
end
