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
  expect(benefit_checker_page.content.dwp_down_warning[1]).to have_text 'You can only process: income-based applications benefits-based applications if the applicant has provided paper evidence'
end

When("I start processing a paper application") do
  dashboard_page.process_application
  personal_details_page.submit_all_personal_details_ni
  application_details_page.submit_fee_600
  savings_investments_page.submit_less_than
  benefits_page.submit_benefits_yes
end

When("I am on the benefits paper evidence page") do
  expect(current_url).to end_with '/applications/1/benefit_override/paper_evidence'
end

Then("I should see that I will need paper evidence for the benefits") do
  expect(benefit_checker_page.content).to have_paper_evidence_warning
end

When("the applicant has not provided the correct paper evidence") do
  benefit_checker_page.content.no.click
  next_page
  click_on 'Complete processing', visible: false
end

When("the applicant has provided the correct paper evidence") do
  benefit_checker_page.content.yes.click
  next_page
  click_on 'Complete processing', visible: false
end

Then("I should see that the applicant fails on benefits") do
  expect(confirmation_page.content).to have_failed_benefits
end

Then("I should see that the applicant passes on benefits") do
  expect(confirmation_page.content).to have_passed_benefits
end
