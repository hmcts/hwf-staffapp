Then("I am on the change details page") do
  click_link 'View profile'
  click_link 'Change details'
  expect(page).to have_current_path(%r{/edit})
end

When("I change my details") do
  fill_in 'Name', with: 'Test User'
  fill_in 'Email', with: 'user_test@digital.justice.gov.uk'
  click_button 'Save changes'
  expect(profile_page.content.notice.text).to have_content 'User updated. We have sent an email with a confirmation link'
end

Then("I can see my profile has been changed") do
  expect(profile_page.content.profile.text).to have_content 'Test User'
end

And("I am on my profile page") do
  click_link 'View profile'
  expect(profile_page.content).to have_header
  expect(profile_page).to have_current_path(%r{/users/})
end

Then("I should see my details") do
  expect(profile_page.content).to have_full_name
  expect(profile_page.content).to have_email
  expect(profile_page.content).to have_role
  expect(profile_page.content).to have_office
  expect(profile_page.content).to have_jurisdiction
  expect(profile_page.content).to have_last_logged_in
end

When("I clink on change your password") do
  click_link 'Change your password'
end

Then("I am taken to change password page") do
  expect(page).to have_current_path(%r{/change_password})
end

Then("I should be taken to the change details page") do
  expect(page).to have_current_path(%r{/edit})
end
