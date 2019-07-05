Given(/^I am on the application details part of the application$/) do
  application_details_page.go_to_application_details_page
  expect(current_path).to include 'details'
  expect(application_details_page.content).to have_header
end

When(/^I successfully submit my required application details$/) do
  application_details_page.submit_fee_600
end

Then(/^I should be taken to savings and investments page$/) do
  expect(current_path).to include 'savings_investments'
  expect(savings_investments_page.content).to have_header
end

When(/^I submit the form without a form number$/) do
  application_details_page.submit_without_form_number
end

Then(/^I should see enter a valid form number error message$/) do
  expect(application_details_page.content).to have_form_error_message
end

When(/^I submit the form with a help with fees form number '(.+?)'$/) do |num|
  application_details_page.content.form_input.set num
  next_page
end

Then(/^I should see you entered the help with fees form number error message$/) do
  expect(application_details_page.content).to have_invalid_form_number_message
end

When(/^I submit the form without a fee amount$/) do
  next_page
end

Then(/^I should see enter a fee error message$/) do
  expect(application_details_page.content).to have_fee_blank_error
end

Then(/^I should see error message telling me that the fee needs to be below £20,000$/) do
  expect(application_details_page.content).to have_exceed_fee_limit_error
end

When(/^I submit the form with a fee £20,000 or over$/) do
  fill_in 'How much is the court or tribunal fee?', with: '20000'
  next_page
end

When("I submit the form with a fee £10,001 - £19,999") do
  application_details_page.submit_fee_1001
end

Then("I should be taken to ask a manager page") do
  expect(current_url).to end_with '/applications/1/approve'
  expect(approve_page.content).to have_header
end
