Given("I am admin on the staff page") do
  staff_page.set_up_multiple_users
  staff_page.admin_on_staff_page
  expect(staff_page).to be_displayed
  expect(staff_page.content).to have_header
end

Given("I am manager on the staff page") do
  staff_page.set_up_multiple_users
  staff_page.manager_on_staff_page
  expect(staff_page).to be_displayed
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
  expect(users_page.content).to have_active_result
  expect(users_page.content).to have_no_inactive_result
end

And("I change the member of staff to a reader") do
  change_user_details_page.content.reader_radio.click
  click_button 'Save changes'
end

Then("I can see that the user is a reader") do
  expect(users_page.content).to have_reader_role
end

When("I click on add staff") do
  click_on 'Add staff', visible: false
end

Then("I am taken to the send invitation page") do
  expect(page).to have_current_path(%r{/users/invitation/new})
end

When("I click on deleted staff") do
  click_on 'Deleted staff', visible: false
end

Then("I am taken to the deleted staff page") do
  expect(page).to have_current_path(%r{/users/deleted})
end

Then("the office filter is disabled") do
  expect(staff_page.content.office_filter).to be_disabled
end
