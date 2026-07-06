Given("I am on the Help with Fees staff application home page") do
  dashboard_page.load_page
end

When("I am not signed in") do
  expect(sign_in_page.content).to have_sign_in_title
  expect(sign_in_page.content).to have_sign_in_alert
end

When("I am redirected to the sign in page") do
  expect(sign_in_page.content).to have_sign_in_title
end

When("I successfully sign in as a user") do
  sign_in_as_user
  expect(dashboard_page.content).to have_find_an_application_heading
end

When("I successfully sign in as a manager") do
  sign_in_as_manager
  expect(dashboard_page.content).to have_find_an_application_heading
end

When("I successfully sign in as admin") do
  sign_in_as_admin
  expect(dashboard_page.content).to have_find_an_application_heading
end

When("I successfully sign in read only user") do
  sign_in_as_reader
  expect(dashboard_page.content).to have_find_an_application_heading
end

When("I successfully sign in as mi") do
  sign_in_as_mi
  expect(dashboard_page.content).to have_find_an_application_heading
end

Then("I am taken to my read only user dashboard") do
  expect(find_application_page.content).to have_find_application_header
  expect(sign_in_page.content).not_to have_your_last_applications
  expect(sign_in_page.content).to have_in_progress_applications
  expect(sign_in_page.content).to have_completed_applications
  expect(dashboard_page.content).to have_no_start_now_button
  expect(dashboard_page.content).to have_no_look_up_button
  expect(sign_in_page.content).to have_no_generate_reports
  expect(sign_in_page.content).to have_no_view_offices
end

Then("I am taken to my user dashboard") do
  expect(dashboard_page.content).to have_start_now_button
  expect(dashboard_page.content).to have_look_up_button
  expect(sign_in_page.content).to have_your_last_applications
  expect(sign_in_page.content).to have_in_progress_applications
  expect(sign_in_page.content).to have_completed_applications
  expect(sign_in_page.content).to have_no_generate_reports
  expect(sign_in_page.content).to have_no_view_offices
end

Then("I am taken to my admin dashboard") do
  expect(find_application_page.content).to have_find_application_header
  expect(sign_in_page.content).to have_generate_reports
  expect(sign_in_page.content).to have_view_offices
  expect(dashboard_page.content).to have_no_start_now_button
  expect(dashboard_page.content).to have_no_look_up_button
  expect(sign_in_page.content).to have_no_in_progress_applications
  expect(sign_in_page.content).to have_no_your_last_applications
  expect(sign_in_page.content).to have_no_completed_applications
end

When("I attempt to sign in with invalid credentials") do
  sign_in_page.invalid_credentials
end

Then("I should see invalid email or password error message") do
  expect(sign_in_page.content).to have_sign_in_error
end

When("I click on forgot your password") do
  sign_in_page.content.forgot_your_password.click
end

Then("I am taken to get a new password page") do
  expect(new_password_page.content).to have_header
end

Then("I see get help") do
  expect(sign_in_page.content.guidance).to have_get_help_header
end

When("I see forgot your password guidance") do
  expect(sign_in_page.content.guidance).to have_forgot_password
  expect(sign_in_page.content.guidance).to have_follow_steps
end

When("I click on the link get a new password") do
  sign_in_page.content.guidance.get_new_password_link.click
end

Then("I should see under don't have an account that I need to contact my manager") do
  expect(sign_in_page.content.guidance).to have_no_account
  expect(sign_in_page.content.guidance).to have_contact_manager
end

When("I see having technical issues") do
  expect(sign_in_page.content.guidance).to have_technical_issues
end

Then("I should be able to send an email to help with fees support") do
  mailto = 'mailto:helpwithfees@justice.gov.uk'
  expect(sign_in_page.content.guidance.email_support['href']).to eq mailto
end

When("I sign out") do
  click_link 'Sign out', visible: false
end

Then("I should be on sign in page") do
  expect(sign_in_page.content).to have_sign_in_title
  expect(sign_in_page.content).to have_sign_in_title
end

Then("I should not see invalid email or password error message") do
  expect(sign_in_page.content).not_to have_sign_in_alert
end
