Given("I have looked up an online application") do
  FactoryBot.create(:online_application, :with_reference, :completed)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  click_on 'Look up'
end

Then("I should see the applicants online personal details") do
  expect(page).to have_text 'Peter Smith'
  expect(process_online_application_page.content).to have_court_fee
  expect(process_online_application_page.content).to have_day_input
  expect(process_online_application_page.content).to have_month_input
  expect(process_online_application_page.content).to have_year_input
  click_on 'Next'
end
