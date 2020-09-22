Given("I process a paper application with high income") do
  start_application
  dashboard_page.process_application
  incomes_page.go_to_incomes_page_100
  incomes_page.submit_incomes_no
end

When("I enter input as £{int}") do |int|
  incomes_page.submit_incomes(int)
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
  click_on 'Look up', visible: false
end

When("I process that application") do
  process_online_application_page.content.group[1].jurisdiction[0].click
  next_page
  complete_processing
end

Given("I have an online application with children") do
  FactoryBot.create(:online_application, :with_reference, :childandincome6065)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  click_on 'Look up', visible: false
end
