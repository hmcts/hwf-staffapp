Given("I am signed in as a user and I see the benefit checker is down") do
  RSpec::Mocks.with_temporary_scope do
    dwp = instance_double('DwpMonitor', state: 'offline')
    DwpMonitor.stub(:new).and_return dwp
    sign_in_page.load_page
    sign_in_page.user_account
  end
  expect(sign_in_page).to have_welcome_user
  expect(benefit_checker_page).to have_dwp_banner_offline
end

Then("I should see a notification telling me that I can only process income-based applications") do
  expect(benefit_checker_page.content.dwp_down_warning[0]).to have_text 'You can only process: income-based applications benefits-based applications if the applicant has provided paper evidence'
end

Then("applications where the applicant has provided paper evidence") do
  expect(benefit_checker_page.content.dwp_down_warning[1]).to have_text 'You can only process income-based applications. Please wait until the DWP checker is available to process online benefits-based applications'
end
