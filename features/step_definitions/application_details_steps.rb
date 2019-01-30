Given("I am on the application details part of the application") do
  submit_required_personal_details
  expect(current_path).to eq '/applications/2/details'
  expect(application_details_page.content).to have_header
end

When("I successfully submit my required application details") do
  application_details_page.submit_with_fee_600
end

Then("I should be taken to savings and investments page") do
  expect(savings_investments_page).to be_displayed
  expect(savings_investments_page.content).to have_header
end
