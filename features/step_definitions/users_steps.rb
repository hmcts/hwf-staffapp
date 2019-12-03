Given("I am on the staff page") do
  navigation_page.proposition_links.view_staff.click
  expect(users_page.content).to have_header
  expect(current_path).to end_with '/users'
end

When("I click on the add staff link") do
  users_page.content.add_staff_link.click
end

Then("I should be taken to the send invitation page") do
  expect(send_invitation_page.content).to have_header
  expect(current_path).to end_with '/users/invitation/new'
end

Then("I click on the deleted users link") do
  users_page.content.deleted_users.click
end

When("I should be taken to the deleted staff page") do
  expect(deleted_staff_page.content).to have_header
  expect(current_path).to end_with '/users/deleted'
end
