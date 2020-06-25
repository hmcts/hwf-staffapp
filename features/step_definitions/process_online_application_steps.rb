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
  expect(process_online_application_page.content.group[0].input[0].value).to eq '450.0'
  expect(process_online_application_page.content.group[2].input[0].value).to eq Time.zone.yesterday.day.to_s
  expect(process_online_application_page.content.group[2].input[1].value).to eq Time.zone.yesterday.month.to_s
  expect(process_online_application_page.content.group[2].input[2].value).to eq Time.zone.yesterday.year.to_s
  expect(process_online_application_page.content.group[3].input[0].value).to eq 'ABC123'
  click_on 'Next'
end
