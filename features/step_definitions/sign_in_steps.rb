Given("I am on the Help with Fees staff application home page") do
  sign_in_page.load_page
end

When("I am not signed in") do
  expect(current_path).to eq '/users/sign_in'
  expect(sign_in_page.content).to have_alert
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

When("I successfully sign in a manager") do
  sign_in_page.manager_account
  expect(sign_in_page).to have_welcome_test_manager
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

