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
