When("I click on change details of a user") do
  click_link 'user'
  expect(staff_details_page.content).to have_header
  staff_details_page.content.change_details_link.click
  expect(change_user_details_page.content).to have_header
end

Then("I can change the user to a user, manager, admin, mi, reader") do
  expect(page).to have_text 'User Manager Admin Mi Reader'
end

Then("I can not change the users role") do
  expect(page).not_to have_text 'User Manager Admin Mi Reader'
end
