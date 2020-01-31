When("I click on see the guides in the footer") do
  click_link('See the guides')
end

Then("I should be taken to the guide page") do
  expect(current_url).to end_with '/guide'
end

Then("I should not see you need to sign in error message") do
  expect(sign_in_page.content).to have_no_sign_in_alert
end
