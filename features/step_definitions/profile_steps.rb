Then("I am on the change details page") do
  navigation_page.navigation_link.view_profile.click
  profile_page.content.change_details_link.click
  expect(change_user_details_page.content).to have_header
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
  navigation_page.navigation_link.view_profile.click
  expect(profile_page.content).to have_header
end
