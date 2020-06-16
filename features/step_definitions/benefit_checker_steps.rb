Given("the benefit checker is down") do
  binding.pry
  stub_request(:post, "#{URI.parse(ENV.fetch('DWP_API_PROXY'))}/api/benefit_checks").to_return(body: "", status: 500)
  sign_in_page.load_page
  sign_in_page.user_account
  expect(sign_in_page).to have_welcome_user
end

Given("I am signed in as a user") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should see a notification telling me that I can only process income-based applications") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("applications where the applicant has provided paper evidence") do
  pending # Write code here that turns the phrase above into concrete actions
end