And("I am on your feedback page") do
  navigation_page.navigation_link.feedback.click
  expect(feedback_page).to have_current_path(%r{/feedback})
  expect(feedback_page.content).to have_user_feedback_header
  expect(feedback_page.content).to have_welcome_feedback
end

When("I successfully submit my feedback") do
  feedback_page.submit_new_feedback
end

Then("I should be taken to my dashboard") do
  expect(page).to have_current_path('/')
end

Then("I should see your feedback has been recorded notification") do
  expect(feedback_page.content).to have_notice
end

Then("I can email if I have an urgent question or something isn't working") do
  expect(feedback_page.content).to have_email_us
  expect(feedback_page.content.email['href']).to eq 'mailto:helpwithfees.feedback@digital.justice.gov.uk'
end
