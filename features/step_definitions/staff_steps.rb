Given("I am admin on the staff page") do
  staff_page.set_up_multiple_users
  staff_page.admin_on_staff_page
  expect(staff_page).to be_displayed
  expect(staff_page.content).to have_header
end

When("I filter by office") do
  select(Office.last.name, from: 'Office')
  staff_page.filter
end

Then("I see all the results for that office") do
  office_name = Office.last.name
  expect(staff_page.content.result_row[1].text).to have_content office_name
end

When("I filter by activity") do
  select('active', from: 'Activity')
  staff_page.filter
end

Then("I see all the results for that activity") do
  expect(users_page.content).to have_active_result
  expect(users_page.content).to have_no_inactive_result
end

When("I click on change details of one of the members of staff") do
  click_link 'Change details'
end

And("I change the member of staff to a reader") do
  change_profile_details_page.content.reader_radio.click
  click_button 'Save changes'
end

Then("I can see that the user is a reader") do
  expect(users_page.content).to have_reader_role
end
