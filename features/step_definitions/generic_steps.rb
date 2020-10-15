Given("I am signed in as a user that has processed an application") do
  user = FactoryBot.create(:user)
  eligable_application(user)
  sign_in_page.load_page
  expect(sign_in_page).to have_current_path(%r{users/sign_in})
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_current_path('/')
end

Given("I am signed in as a user that has processed multiple applications") do
  user = FactoryBot.create(:user)
  create_multiple_applications(user)
  sign_in_page.load_page
  expect(sign_in_page).to have_current_path(%r{users/sign_in})
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_current_path('/')
end

When("I click on next without making a selection") do
  click_button('Next')
end

Then("I should see select from one of the options error message") do
  expect(base_page.content).to have_select_from_list_error
end

When("I click on save changes") do
  click_on 'Save changes', visible: false
end

Then("I should see your changes have been saved message") do
  expect(base_page.content).to have_saved_alert
end

Given("I have evidence check application") do
  user = FactoryBot.create(:user)
  waiting_evidence_application_ni(user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_current_path('/')
end
