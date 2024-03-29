When("I click on view profile") do
  navigation_page.navigation_link.view_profile.click
end

Then("I am taken to my details") do
  expect(profile_page.content).to have_header
end

When("I click on staff guides") do
  navigation_page.navigation_link.staff_guides.click
end

Then("I am taken to the staff guides page") do
  expect(guide_page.content).to have_guide_header
end

When("I click on feedback") do
  navigation_page.navigation_link.feedback.click
end

Then("I am taken to the feedback page") do
  expect(feedback_page.content).to have_user_feedback_header
end

When("I click on letter templates") do
  navigation_page.navigation_link.letter_templates.click
end

When("I click on old letter templates") do
  navigation_page.navigation_link.old_letter_templates.click
end

When("I click on new letter templates") do
  navigation_page.navigation_link.new_letter_templates.click
end

Then("I am taken to the letter templates page") do
  expect(letter_template_page.content).to have_header
end

Then("I am taken to the old letter templates page") do
  expect(old_letter_template_page.content).to have_header
end

Then("I am taken to the new letter templates page") do
  expect(new_letter_template_page.content).to have_header
end

When("I click on sign out") do
  navigation_page.navigation_link.sign_out.click
end

Then("I am taken to the sign in page") do
  expect(sign_in_page).to be_displayed
  expect(sign_in_page.content).to have_user_email
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

Then("I should see the status of the DWP connection") do
  expect(dashboard_page).to have_css('.dwp-tag')
end

When("I start to process a new paper application") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
end

Given("I successfully sign in as a user who has an online application reference number") do
  FactoryBot.create(:online_application, :with_reference, :completed)
  sign_in_page.load_page
  sign_in_page.user_account
end

Given("I successfully sign in as a user who has an online application that will be hmrc checked") do
  ni_number = "AB123#{Random.rand(9)}#{Random.rand(9)}#{Random.rand(9)}C"
  FactoryBot.create(:online_application, :with_reference, :income, :completed, ni_number: ni_number)
  FactoryBot.create(:application, :waiting_for_evidence_state, :applicant_full, ni_number: ni_number)
  sign_in_page.load_page
  sign_in_page.hmrc_user_account
end

When("I look up an online application using a valid reference number") do
  reference = OnlineApplication.last.reference
  dashboard_page.content.online_search_reference.set reference
  dashboard_page.click_look_up
end

When("I look up an online application using an invalid reference number") do
  dashboard_page.content.online_search_reference.set 'invalid'
  dashboard_page.click_look_up
end

Then("I see an error message saying the reference number is not recognised") do
  expect(dashboard_page.content).to have_online_search_reference_error
end

When("I search for an application using an invalid hwf reference") do
  expect(find_application_page.content).to have_find_application_header
  find_application_page.content.wait_until_search_input_visible
  find_application_page.content.search_input.set "invalid"
  find_application_page.content.search_button.click
end

Then("I see an error message saying no results found") do
  expect(dashboard_page.content).to have_find_application_error
end

When("I click on the reference number of one of my last applications") do
  dashboard_page.content.last_application_link.click
end

Then("I am taken to the processed application") do
  expect(processed_application_instance_page.content).to have_header
  expect(processed_application_instance_page).to be_displayed
end

Then("I am taken to the application waiting for evidence") do
  expect(evidence_page.content).to have_waiting_for_evidence_instance_header
end

Then("I am taken to the application waiting for part-payment") do
  expect(part_payment_page.content).to have_waiting_for_part_payment_instance_heading
end

Given("I am signed in as a user that has processed an application that is waiting for evidence") do
  user = FactoryBot.create(:user)
  waiting_evidence_application_ni(user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_welcome_user
end

Given("I am signed in as a user that has processed an application that is a part payment") do
  user = FactoryBot.create(:user)
  part_payment_application(user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_welcome_user
end

Given('I am signed in as a user that has processed an application that is a waiting for hmrc evidence') do
  user = FactoryBot.create(:user)
  waiting_hmrc_evidence_application(user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_welcome_user
end

Then('I am taken to the hmrc check page') do
  expect(hmrc_income_check_page.content).to have_header
end

When("I click on the waiting for evidence link") do
  dashboard_page.content.waiting_for_evidence.click
end

When("I click on the evidence check list link") do
  waiting_for_evidence_applications_page.content.waiting_for_evidence_application_link.click
end

Then("I am taken to the waiting for evidence page") do
  expect(waiting_for_evidence_applications_page.content).to have_header
end

When("I click on the waiting for part payments link") do
  dashboard_page.content.waiting_for_part_payment.click
end

Then("I am taken to the waiting for part payments page") do
  expect(waiting_for_part_payment_applications_page.content).to have_header
end

When("I click on processed applications") do
  dashboard_page.content.processed_applications.click
end

Then("I am taken to all processed applications") do
  expect(processed_applications_page).to be_displayed
  expect(processed_applications_page.content.header.text).to eq "Processed applications"
end

When("I click on deleted applications") do
  dashboard_page.content.deleted_applications.click
end

Then("I am taken to all deleted applications") do
  expect(deleted_applications_page).to be_displayed
  expect(deleted_applications_page.content).to have_header
end
