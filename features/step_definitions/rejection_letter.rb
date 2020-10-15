Given("I process a paper application with high income") do
  start_application
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.process_application
  expect(application_details_page).to have_current_path(%r{/applications/[0-9]+/personal_informations})
  personal_details_page.submit_required_personal_details
  expect(application_details_page).to have_current_path(%r{/applications/[0-9]+/details})
  application_details_page.submit_fee_100
  expect(savings_investments_page).to have_current_path(%r{/applications/[0-9]+/savings_investments})
  savings_investments_page.submit_less_than
  expect(benefits_page).to have_current_path(%r{/applications/[0-9]+/benefits})
  benefits_page.submit_benefits_no
  expect(incomes_page).to have_current_path(%r{/applications/[0-9]+/incomes})
  incomes_page.submit_incomes_no
end

When("I enter input as £{int}") do |int|
  incomes_page.submit_incomes(int)
  expect(incomes_page).to have_current_path(%r{applications/[0-9]+/summary})
  complete_processing
end

Then("the rejection letter should state {string}") do |string|
  expect(page).to have_text(string)
end

Given("I have an online application with high income") do
  FactoryBot.create(:online_application, :with_reference, :income_6065, :completed)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end

When("I process that application") do
  expect(process_online_application_page).to have_current_path(%r{/online_applications/[0-9]+/edit})
  process_online_application_page.content.group[1].jurisdiction[0].click
  process_online_application_page.click_next
  complete_processing
end

Given("I have an online application with children") do
  FactoryBot.create(:online_application, :with_reference, :childandincome6065)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end

Given("I have an online application with big savings") do
  FactoryBot.create(:online_application, :with_reference, :big_saving)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end

Given("I have an online application with medium savings") do
  FactoryBot.create(:online_application, :with_reference, :threshold_exceeded, :completed)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end
