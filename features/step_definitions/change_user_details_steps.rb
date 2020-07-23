When("I click on change details of a user") do
  click_link 'user'
  click_link 'Change details'
end

Then("I can change the user to a user, manager, admin, mi, reader") do
  expect(page).to have_text 'User Manager Admin Mi Reader'
end

Then("I can not change the users role") do
  expect(page).to have_no_text 'User Manager Admin Mi Reader'
end

And("I change the jurisdiction") do
  expect(change_user_details_page.content.radio[6].text).to have_content Jurisdiction.first.name
  change_user_details_page.content.radio[6].click
  click_button 'Save changes'
end

When("I should see the jurisdiction has been updated") do
  expect(staff_details_page.content.table_row[4].text).to have_text "Main jurisdiction #{Jurisdiction.first.name}"
end
