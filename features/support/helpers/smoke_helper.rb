Given('I am signed in as a smoke user') do
  page.driver.browser.url_blacklist = ['**/assets/**']
  visit 'users/sign_in'
  expect(page).to have_content('Sign in', wait: 10)

  sign_in_page.sign_in_as_smoke_user
end

Given('I am on the home page') do
  visit root_path
  expect(page).to have_content('Process a paper application')
end

Given('start processing paper application') do
  dashboard_page.process_application
end

Then('I fill in fee status page details') do
  expect(fee_status_page.content).to have_header
  fee_status_page.fill_in_date_received
  fee_status_page.content.refund_false.click
  fee_status_page.click_next
end

Then('I fill in personal details page details') do
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_required_personal_details
end

Then('I fill in application details page') do
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
end

Then('the applicants has less savings then minimum threshold') do
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
end

Then('the applicant is not on benefits') do
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
end

Then('has no children') do
  expect(children_page.content).to have_header
  children_page.no_children
end

Then('has income just from wages') do
  expect(income_kind_applicant_page.content).to have_header
  income_kind_applicant_page.content.checkboxes[0].click
  income_kind_applicant_page.click_next
end

Then('the amount of income is 50 for last month') do
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_50_ucd
end

Then('the applicant is filling the application just for themselves') do
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
end

Then('I should see check details page') do
  expect(summary_page.content).to have_header
  expect(summary_page.content.summary_section[3].list_row[0].text).to have_content 'Less than £4,250 Yes ChangeLess than £4,250'
  expect(summary_page.content.summary_section[6].list_row[0].text).to have_content 'Total income £50 ChangeTotal income'
end

When('I complete the application') do
  complete_processing
end

Then('I should see the confirmation page') do
  expect(confirmation_page.content).to have_application_complete
end

Then('the application is marked to be evidence_checked') do
  expect(confirmation_page.content.text).to have_content 'Evidence of income needs to be checked'
end
