When("I click on change details of a user") do
  click_link 'user'
  expect(page).to have_current_path(%r{/users/[0-9]+})
  click_link 'Change details'
  expect(page).to have_current_path(%r{/users/[0-9]+/edit})
end

Then("I can change the user to a user, manager, admin, mi, reader") do
  expect(page).to have_text 'User Manager Admin Mi Reader'
end

Then("I can not change the users role") do
  expect(page).to have_no_text 'User Manager Admin Mi Reader'
end
