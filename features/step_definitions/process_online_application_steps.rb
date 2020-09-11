Given("I have looked up an online application") do
  FactoryBot.create(:online_application, :with_reference, :completed)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  click_on 'Look up', visible: false
end

When("I see the application details") do
  expect(process_online_application_page.content).to have_application_details_header
  expect(process_online_application_page).to have_text 'Peter Smith'
  expect(process_online_application_page.content.group[0].input[0].value).to eq '450.0'
  expect(process_online_application_page.content.group[2].input[0].value).to eq Time.zone.yesterday.day.to_s
  expect(process_online_application_page.content.group[2].input[1].value).to eq Time.zone.yesterday.month.to_s
  expect(process_online_application_page.content.group[2].input[2].value).to eq Time.zone.yesterday.year.to_s
  expect(process_online_application_page.content.group[3].input[0].value).to eq 'ABC123'
end

And("I click next without selecting a jurisdiction") do
  next_page
end

Then("I should see that I must select a jurisdiction error message") do
  expect(process_online_application_page.content).to have_error
end

Then("I add a jurisdiction") do
  process_online_application_page.content.group[1].jurisdiction[0].click
  next_page
end

Then("I should be taken to the check details page") do
  expect(process_online_application_page.content).to have_check_details_header
  expect(process_online_application_page).to have_current_path(%r{/online_applications})
end

When("I process the online application") do
  process_online_application_page.content.group[1].jurisdiction[0].click
  next_page
  complete_processing
end

Then("I see the applicant is not eligible for help with fees") do
  expect(process_online_application_page.content).to have_not_eligible_header
  expect(process_online_application_page.content.summary_row[1]).to have_text 'Savings and investments ✓ Passed'
  expect(process_online_application_page.content.summary_row[2]).to have_text 'Benefits ✗ Failed'
end

And("back to start takes me to the homepage") do
  click_on 'Back to start', visible: false
  expect(page).to have_current_path('/')
end

And("I can see my processed application") do
  expect(process_online_application_page.content.last_application[1].text).to have_content 'processed Peter Smith'
end
