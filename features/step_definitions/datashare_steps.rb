Given(/^I fill in the form details for a low income user$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.group[1].jurisdiction[0].click
  low_income
  click_button('Next')
end

When(/^I press complete processing$/) do
  expect(process_online_application_page.content).to have_check_details_header
  click_button('Complete processing')
end

And(/^I check the income for the correct month$/) do
  expect(datashare_evidence_page.content).to have_checked_header
  click_button('Submit')
end

And(/^There is no additional income for the user$/) do
  expect(datashare_evidence_page.content).to have_checked_header
  click_button('Next')
  click_button('Complete processing')
end

Then(/^I should see application complete$/) do
  expect(datashare_evidence_page.content).to have_application_complete_header
end

Given(/^I fill in the form details for a medium income user$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.group[1].jurisdiction[0].click
  click_button('Next')
end

Then(/^I should see waiting for part payment$/) do
  expect(datashare_evidence_page.content).to have_text('You’re eligible to get some money taken off')
end

Given(/^I fill in the form details for a higher income user$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.group[1].jurisdiction[0].click
  click_button('Next')
end

Then(/^I should see not eligible for help with fees$/) do
  expect(datashare_evidence_page.content).to have_not_eligible_header
end

Given(/^I fill in the form details for an applicant with working tax credit$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.group[1].jurisdiction[0].click
  click_button('Next')
end
