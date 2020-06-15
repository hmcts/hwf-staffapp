When("I click on change details of a user") do
  click_link 'user'
  click_link 'Change details'
end

Then("I can change the user to a user, manager, admin, mi, reader") do
  expect(change_user_details_page.content).to have_user_radio
  expect(change_user_details_page.content).to have_manager_radio
  expect(change_user_details_page.content).to have_admin_radio
  expect(change_user_details_page.content).to have_mi_radio
  expect(change_user_details_page.content).to have_reader_radio
end

Then("I can not change the users role") do
  expect(change_user_details_page.content).to have_no_user_radio
  expect(change_user_details_page.content).to have_no_manager_radio
  expect(change_user_details_page.content).to have_no_admin_radio
  expect(change_user_details_page.content).to have_no_mi_radio
  expect(change_user_details_page.content).to have_no_reader_radio
  expect(change_user_details_page.content).to have_role
end

And("I change the jurisdiction") do
  expect(change_user_details_page.content.radio[6].text).to have_content Jurisdiction.first.name
  change_user_details_page.content.radio[6].click
  click_button 'Save changes'
end

When("I should see the jurisdiction has been updated") do
  expect(staff_details_page.content.table_row[4].text).to have_text "Main jurisdiction #{Jurisdiction.first.name}"
end
