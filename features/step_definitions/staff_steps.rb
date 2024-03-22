Given("I am admin on the staff page") do
  staff_page.set_up_multiple_users
  sign_in_page.load_page
  expect(sign_in_page.content).to have_sign_in_title
  sign_in_page.admin_account
  expect(dashboard_page.content).to have_find_an_application_heading
  navigation_page.navigation_link.view_staff.click
  expect(staff_page.content).to have_header
end

Given("I am manager on the staff page") do
  staff_page.set_up_multiple_users
  sign_in_page.load_page
  expect(sign_in_page.content).to have_sign_in_title
  sign_in_page.manager_account
  expect(change_user_details_page.content).to have_header
  navigation_page.navigation_link.view_staff.click
  expect(staff_page.content).to have_header
end

When("I filter by office") do
  select(Office.last.name, from: 'Office')
  click_button 'Filter'
end

Then("I see all the results for that office") do
  expect(staff_page.content.result_row[1].text).to have_content Office.last.name
end

When("I filter by activity") do
  select('active', from: 'Activity')
  click_button 'Filter'
end

Then("I see all the results for that activity") do
  expect(staff_page.content).to have_active_result
  expect(staff_page.content).to have_no_inactive_result
end

And("I change the member of staff to a reader") do
  change_user_details_page.content.reader_radio.click
  click_button 'Save changes'
end

Then("I can see that the user is a reader") do
  expect(staff_page.content).to have_reader_role
  expect(staff_page).to have_content("User updated.")
end

And("I change the jurisdiction") do
  user = User.find(current_path.match('\d+').to_s)
  jurisdiction = user.office.jurisdictions.first
  change_user_details_page.content.wait_until_header_visible
  # revisit this if the test keep failing - the params were missing jurisdiction id
  expect(change_user_details_page.content.radio[6].text).to have_content jurisdiction.name
  change_user_details_page.content.find('label', text: jurisdiction.name).click
  change_user_details_page.content.save_changes_button.click
  expect(staff_details_page.content).to have_header
end

Then("I should see the jurisdiction has been updated") do
  user = User.find(current_path.match('\d+').to_s)
  jurisdiction = user.jurisdiction
  # fails faster if check the data first - for this case only
  expect(user.jurisdiction&.name).to eql(user.office.jurisdictions.first.name)
  staff_details_page.content.wait_until_header_visible
  expect(staff_details_page.content.table_row[4].text).to have_text "Main jurisdiction #{jurisdiction.name}"
end

When("I click on add staff") do
  click_on 'Add staff', visible: false
end

Then("I am taken to the send invitation page") do
  expect(page).to have_content 'Send invitation'
end

When("I click on deleted staff") do
  click_on 'Deleted staff', visible: false
end

Then("I am taken to the deleted staff page") do
  expect(page).to have_text 'Deleted staff'
end

Then("the office filter is disabled") do
  expect(staff_page.content.office_filter).to be_disabled
end
