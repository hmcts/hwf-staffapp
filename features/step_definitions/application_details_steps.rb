Given(/^I am on the application details part of the application$/) do
  submit_required_personal_details
  expect(current_path).to include 'details'
  expect(application_details_page.content).to have_header
end

When(/^I successfully submit my required application details$/) do
  application_details_page.submit_with_fee_600
end

Then(/^I should be taken to savings and investments page$/) do
  expect(current_path).to include 'savings_investments'
  expect(savings_investments_page.content).to have_header
end

When(/^I submit the form without a number$/) do
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
