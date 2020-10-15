Given("I fill in personal details of the application") do
  expect(personal_details_page).to have_current_path(%r{/personal_informations})
  personal_details_page.submit_all_personal_details_ni
end

Given("I fill in the application details") do
  expect(application_details_page).to have_current_path(%r{/details})
  application_details_page.submit_fee_600
end

Given("I abandon the application") do
  expect(savings_investments_page).to have_current_path(%r{/savings_investments})
  savings_investments_page.go_home
end

When("I open my last application") do
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.content.last_application_link.click
end

Then("I should see the personal details populated with information") do
  expect(personal_details_page.content.application_first_name['value']).to eq 'John Christopher'
  personal_details_page.click_next
end

Then("I should see the application details populated with information") do
  expect(application_details_page.content.form_input['value']).to eq 'C100'
end
