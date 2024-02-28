Given('I have started a paper application') do
  sign_in_as_user
  enable_feature_switch('band_calculation')
  dashboard_page.process_application
end

When('I fill in date fee received to today') do
  fee_status_page.fill_in_date_received(Time.zone.now)
end

When('I choose no to a fee paid and press Next') do
  fee_status_page.content.refund_false.click
  fee_status_page.click_next
end

When('I fill in name and date of birth of single applicant and submit') do
  personal_details_page.fill_in_single_applicant
  personal_details_page.click_next
end

When('I fill in {int} fee and jurisdiction') do |int|
  application_details_page.fill_in('How much is the court or tribunal fee?', with: int)
  application_details_page.content.jurisdiction.click
end

When('I fill in form number and press Next') do
  application_details_page.content.form_input.set 'CF100'
  application_details_page.click_next
end

Then('I am on the savings and investments page') do
  expect(savings_investments_page).to be_displayed
end

When('I choose less then option and press Next') do
  savings_investments_page.submit_less_than_ucd
end

Then('I am on the benefits the applicant is receiving page') do
  expect(benefits_page).to be_displayed
end

When('I choose no to receiving benefits question and press Next') do
  benefits_page.submit_benefits_no
end

Then('I am on the children page') do
  expect(children_page).to be_displayed
end

When('I choose no to do you support any children question and press Next') do
  children_page.no_children
end

Then('I am on the type of income the applicant is receiving page') do
  expect(income_kind_applicant_page).to be_displayed
end

When('I select wages and universal credit and press Next') do
  income_kind_applicant_page.content.wages.click
  income_kind_applicant_page.content.universal_credit.click
  income_kind_applicant_page.click_next
end

Then('I am on the income page') do
  expect(incomes_page).to be_displayed
end

When('I fill in {int} for income') do |_int|
  incomes_page.fill_income_post_ucd(1500)
end

When('I choose last calendar month and press Next') do
  incomes_page.content.income_period_last_month.click
  incomes_page.click_next
end

Then('I am on the declaration and statement of truth page') do
  expect(declaration_page).to be_displayed
end

When('I choose Applicant and press Next') do
  declaration_page.sign_by_applicant
end

Then('I am on the check details page') do
  expect(summary_page).to be_displayed
end

Then('I should see today date received date') do
  summary.date_received(Time.zone.today)
end

Then('I should see no refund') do
  summary.refund('No')
end

Then('I should see Full name') do
  summary.full_name('John Smith')
end

Then('I should see dob') do
  summary.dob('10 February 1986')
end

Then('I should see single status') do
  summary.marriage_status('Single')
end

Then('I should see Fee {int}') do |int|
  summary.fee(int)
end

Then('I should see correct jurisdiction') do
  summary.jurisdiction
end

Then('I should see Form number') do
  summary.form_number('CF100')
end

Then('I should see Less than £4,250 to be Yes') do
  summary.saving_less('Yes')
end

Then('I should see Less than £4,250 to be No') do
  summary.saving_less('No')
end

Then('I should see Between £4,250 and £15,999 to be Yes') do
  summary.saving_between('Yes')
end

Then('I should see Between £4,250 and £15,999 to be No') do
  summary.saving_between('No')
end

Then('I should see More than £16,000 to be Yes') do
  summary.saving_more('Yes')
end

Then('I should see More than £16,000 to be No') do
  summary.saving_more('No')
end

Then('I should see Benefits to be No') do
  summary.benefits('No')
end

Then('I should see Benefits to be Yes') do
  summary.benefits('Yes')
end

Then('I should see Children to be No') do
  summary.children('No')
end

Then('I should see Children to be Yes') do
  summary.children('Yes')
end

Then('I should see Income with value {int}') do |int|
  summary.income(int)
end

Then('I should see Income period to be last calendar month') do
  summary.income_period('This is for the last calendar month')
end

Then('I should see Applicant income type to be wages and universal credit') do
  summary.income_type('Wages, Universal Credit')
end

Then('I should see Declaration statement to be applicant') do
  summary.declaration('Applicant')
end

When('I press Complete processing') do
  summary.complete_processing
end

Then('I should see {string} text') do |string|
  expect(confirmation_page.content.text).to have_text string
end

Then('I should see that savings passed') do
  confirmation_page.savings_passed
end

Then('I should see that income is part payment') do
  confirmation_page.income_waiting_for_part_payment
end

Then('I should see that new HwF scheme applies') do
  confirmation_page.new_hwf_schema
end

When('I click Back to start') do
  confirmation_page.back_to_start
end

Then('I should see that my last application has waiting_for_part_payment status') do
  expect(dashboard_page.content.last_application[1]).to have_text 'waiting_for_part_payment'
end

When('I click on the reference number') do
  dashboard_page.open_my_last_application
end

Then('I am on the waiting for part-payment page') do
  expect(part_payment_page).to be_displayed
end

Then('press Start now') do
  part_payment_page.start_processing
end

Then('I am on part payment ready to process page') do
  expect(part_payment_ready_to_process_page).to be_displayed
end

When('I am choose Yes and press Next') do
  part_payment_ready_to_process_page.ready_to_process_payment
end

Then('I am on check details pages for part payment process page') do
  expect(part_payment_summary_page).to be_displayed
end

Then('I should see Processing complete') do
  expect(part_payment_confirmation_page).to be_displayed
  expect(part_payment_confirmation_page.content).to have_processed_header
end

Then('I should see that my last application has processed status') do
  expect(dashboard_page.content.last_application[1]).to have_text 'processed'
end
