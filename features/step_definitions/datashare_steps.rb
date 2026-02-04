Given(/^I fill in the form details for a low income user$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  hmrc_low_income
  click_button('Next')
end

When(/^I press complete processing$/) do
  expect(process_online_application_page.content).to have_check_details_header
  click_button('Complete processing')
end

And(/^I check the income for the correct month$/) do
  expect(datashare_evidence_page.content).to have_checking_header
  click_button('Submit')
end

And(/^There is no additional income for the user$/) do
  expect(datashare_evidence_page.content).to have_checked_header
  click_button('Next')
  click_button('Complete processing')
end

And(/^There is an error message on income page$/) do
  expect(datashare_evidence_page.content).to have_checked_header
  expect(datashare_evidence_page.content).to have_entitlement_error
  click_button('Next')
end

Then(/^I should see application complete$/) do
  expect(datashare_evidence_page.content).to have_application_complete_header
end

Given(/^I fill in the form details for a medium income user$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  hmrc_medium_income
  click_button('Next')
end

Then(/^I should see waiting for part payment$/) do
  expect(datashare_evidence_page.content).to have_text('The applicant is eligible to get some money taken off')
end

Given(/^I fill in the form details for a higher income user$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  hmrc_high_income
  click_button('Next')
end

Then(/^I should see not eligible for help with fees$/) do
  expect(datashare_evidence_page.content).to have_not_eligible_header
end

Given(/^I fill in the form details for an applicant with working tax credit$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  hmrc_working_tax_credits
  click_button('Next')
end

Given(/^I fill in the form details for an applicant with recalculated tax credit$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  hmrc_recalculated_tax_credits
  click_button('Next')
end

Then(/^I should see the result for that application$/) do
  expect(datashare_evidence_page.content).to have_text('Application complete')
end

Then(/^Evidence needs to be checked manualy$/) do
  expect(datashare_evidence_page.content).to have_text('Evidence of income needs to be checked')
end

Given(/^I fill in the form details for an applicant with child tax credit$/) do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  hmrc_child_tax_credits
  click_button('Next')
end
