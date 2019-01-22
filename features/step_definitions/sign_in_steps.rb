Given("I am on the Help with Fees staff application home page") do
  sign_in_page.load_page
end

When("I am not signed in") do
  expect(current_path).to eq '/users/sign_in'
  expect(sign_in_page.content).to have_sign_in_alert
end

When("I am redirected to the sign in page") do
  expect(current_path).to eq '/users/sign_in'
end

When("I successfully sign in as a user") do
  sign_in_page.user_account
  expect(sign_in_page).to have_welcome_test_user
end

When("I successfully sign in as admin") do
  sign_in_page.admin_account
  expect(sign_in_page).to have_welcome_test_admin
end

Then("I am taken to my user dashboard") do
  expect(sign_in_page.content).to have_waiting_for_evidence
  expect(sign_in_page.content).to have_waiting_for_part_payment
  expect(sign_in_page.content).to have_your_last_applications
  expect(sign_in_page.content).to have_completed_applications
  expect(sign_in_page.content).to have_no_generate_reports
  expect(sign_in_page.content).to have_no_view_offices
end

Then("I am taken to my admin dashboard") do
  expect(sign_in_page.content).to have_generate_reports
  expect(sign_in_page.content).to have_view_offices
  expect(sign_in_page.content).to have_no_waiting_for_evidence
  expect(sign_in_page.content).to have_no_waiting_for_part_payment
  expect(sign_in_page.content).to have_no_your_last_applications
  expect(sign_in_page.content).to have_no_completed_applications
end

When("I attempt to sign in with invalid credentials") do
  sign_in_page.invalid_credentials
end

# this is not the correct GDS behaviour
Then("I should see invalid email or password error message") do
  expect(sign_in_page.content).to have_sign_in_alert
end

When("I click on forgot your password") do
  sign_in_page.content.forgot_your_password.click
end

Then("I am taken to get a new password page") do
  expect(current_path).to eq '/users/password/new'
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
  mailto = 'mailto:helpwithfees.support@digital.justice.gov.uk'
  expect(sign_in_page.content.guidance.email_support['href']).to eq mailto
end
