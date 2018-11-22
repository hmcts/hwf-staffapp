Given("I am on the Help with Fees staff application home page") do
  sign_in_page.load_page
end

When("I am not signed in") do
  expect(current_path).to eq '/users/sign_in'
  expect(sign_in_page.content).to have_alert
end

When("I am redirected to the sign in page") do
  expect(current_path).to eq '/users/sign_in'
end

When("I successfully sign in as admin") do
  sign_in_page.admin_account
  expect(sign_in_page.content).to have_signed_in_alert
end

When("I successfully sign in as a user") do
  sign_in_page.admin_account
  expect(sign_in_page.content).to have_signed_in_alert
end

Then("I am taken to my dashboard") do
  binding.pry
end

