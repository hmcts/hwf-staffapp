Given("I am signed in as admin on the staff page") do
  sign_in_page.load_page
  sign_in_page.admin_account
  navigation_page.navigation_link.view_staff.click
end

When("I filter by office") do
  office = User.last.office.name
  select office, from: "Office"
  staff_page.content.filter_button.click
end

Then("I see all the results for that office") do
  selected_office = User.last.office.name
  office_result = staff_page.content.office_result.text
  expect(selected_office).to eq office_result
end

When("I filter by activity") do
  select 'active', from: 'Activity'
  staff_page.content.filter_button.click
end

Then("I see all the results for that activity") do
  expect(staff_page.content).to have_activity_flag
end

When("I click on change details of one of the members of staff") do
  click_on 'Change details'
end

Then("I change the details of that member of staff") do
  expect(edit_staff_page).to be_displayed
  expect(edit_staff_page.content).to have_header
  fill_in 'Name', with: 'Admin'
  click_button 'Save changes'
end

When("I click on add staff") do
  click_on 'Add staff'
end

Then("I am taken to the send invitation page") do
  expect(current_path).to eq '/users/invitation/new'
end

When("I click on deleted staff") do
  click_on 'Deleted staff'
end

Then("I am taken to the deleted staff page") do
  expect(current_path).to eq '/users/deleted'
end

Then("I am taken to the staff details page") do
  expect(current_path).to eq '/users/1'
end

Then("I can see the details have been changed") do
  expect(staff_details_page.content).to have_user_updated
  expect(staff_details_page.content).to have_table_row
end
