Given("I am on the litigation details page") do
  litigation_details_page.go_to_litigation_details_page
  expect(litigation_details_page.content).to have_header
  expect(current_path).to end_with '/litigation_details'
end

When("I successfully submit litigation details") do
  litigation_details_page.submit_litigation_details
end

When("I click next without adding the applicants litigation details") do
  next_page
end

Then("I should see enter applicants litigation details error message") do
  expect(litigation_details_page.content).to have_error
end
