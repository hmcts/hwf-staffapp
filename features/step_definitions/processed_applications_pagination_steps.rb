Given("I am signed in as a user that has 50 processed applications") do
  sign_in_page.load_page
  expect(sign_in_page).to have_current_path('/users/sign_in')
  sign_in_page.user_account_with_50_applications
  expect(dashboard_page).to have_current_path('/')
end

Given("I click 15 per page") do
  processed_applications_page.select_fifteen_per_page
  expect(processed_applications_page).to have_current_path(/per_page=15/)
end

When("I click on the number representing the last page") do
  processed_applications_page.click_last_page_number
  expect(processed_applications_page).to have_current_path(/page=4/)
  expect(processed_applications_page.content.which_page.text).to eq 'Page 4 of 4'
end

When("I click on the number representing the first page") do
  processed_applications_page.click_first_page_number
end

Then("I should be on page 4") do
  expect(processed_applications_page).to have_current_path(/page=4/)
  expect(processed_applications_page.content.which_page.text).to eq 'Page 4 of 4'
end

Then("I should be on page 1") do
  expect(processed_applications_page).to have_current_path(/page=1/)
  expect(processed_applications_page.content.which_page.text).to eq 'Page 1 of 4'
end

When("I click Next page button") do
  processed_applications_page.click_next_page_button
  expect(processed_applications_page.content.which_page.text).to eq 'Page 2 of 4'
end

When("I click Previous page button") do
  processed_applications_page.click_previous_page_button
end
