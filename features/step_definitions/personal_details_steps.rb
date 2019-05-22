Given("I have started an application") do
  start_application
end

And("I am on the personal details part of the application") do
  expect(current_path).to include 'personal_informations'
  expect(personal_details_page.content).to have_header
end

When("I successfully submit my required personal details") do
  personal_details_page.submit_required_personal_details
end

Then("I should be taken to the application details page") do
  expect(current_path).to include 'details'
  expect(application_details_page.content).to have_header
end

When("I submit a date that makes the applicant under 16 years old") do
  personal_details_page.under_16_dob
  next_page
end

Then("I should see that the applicant cannot be under 16 years old error message") do
  expect(personal_details_page.content).to have_under_16_error
end

Then("I should see the invalid date of birth error message") do
  expect(personal_details_page.content).to have_invalid_date_of_birth_error
end

When("I leave the date of birth blank") do
  next_page
end
