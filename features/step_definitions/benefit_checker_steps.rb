Given("I am signed in as a user and I see the benefit checker is down") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as("offline")
    user = FactoryBot.create(:user)
    sign_in_page.load_page
    sign_in_page.sign_in_with(user)
    expect(dashboard_page).to have_dwp_offline_banner
    expect(dashboard_page.content).to have_find_an_application_heading
  end
end

Given("I have looked up an online application when the benefit checker is down") do
  RSpec::Mocks.with_temporary_scope do
    dwp = instance_double('DwpMonitor', state: 'offline')
    DwpMonitor.stub(:new).and_return dwp
    FactoryBot.create(:online_application, :with_reference, :completed, calculation_scheme: 'post_ucd')
    sign_in_page.load_page
    expect(sign_in_page.content).to have_sign_in_title
    sign_in_page.user_account
    expect(dashboard_page.content).to have_find_an_application_heading
    reference = OnlineApplication.last.reference
    fill_in 'Reference', with: reference
    expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
    dashboard_page.click_look_up
  end
end

Then("I should see a notification telling me that I can only process income-based applications or where the applicant has provided paper evidence") do
  expect(benefit_checker_page.content.dwp_down_warning).to have_text 'You can only process: income-based applications benefits-based applications if the applicant has provided supporting evidence'
end

When("I start processing a paper application with no benefits record") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_with_no_answer_for_benefits
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  dwp_monitor_state_as('offline')
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_benefit_question
  benefits_page.submit_benefits_yes
end

When("I start processing a paper application with undetermined benefits check") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_with_no_answer_for_benefits
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  dwp_monitor_state_as('offline')
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_benefit_question
  benefits_page.submit_benefits_yes
end

When("I am on the benefits paper evidence page") do
  expect(benefit_checker_page.content).to have_header
  benefit_checker_page.content.wait_until_paper_evidence_warning_visible
end

Then("I should see that I will need paper evidence for the benefits") do
  expect(benefit_checker_page.content).to have_paper_evidence_warning
end

When("the applicant has not provided the correct paper evidence") do
  benefit_checker_page.content.no.click
  benefit_checker_page.click_next
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
end

When("the applicant has not provided the correct paper evidence without declaration") do
  benefit_checker_page.content.no.click
  benefit_checker_page.click_next
  expect(summary_page.content).to have_header
  complete_processing
end

When("the applicant has provided the correct paper evidence without declaration") do
  benefit_checker_page.content.wait_until_yes_visible
  benefit_checker_page.content.yes.click
  benefit_checker_page.click_next
  expect(summary_page.content).to have_header
  complete_processing
end

When("the applicant has provided the correct paper evidence") do
  benefit_checker_page.content.wait_until_yes_visible
  benefit_checker_page.content.yes.click
  benefit_checker_page.click_next
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
end

Then("I should see that the applicant fails on benefits") do
  expect(confirmation_page.content).to have_reference_number_is
  expect(confirmation_page.content).to have_failed_benefits
end

Then("I should see that the online applicant fails on benefits") do
  expect(process_online_application_page.content).to have_reference_number_is
  expect(process_online_application_page.content).to have_failed_benefits
end

Then("I should see that the applicant passes on benefits") do
  expect(confirmation_page.content).to have_reference_number_is
  expect(confirmation_page.content).to have_passed_benefits
end

Given("the benefit checker is down") do
  RSpec::Mocks.with_temporary_scope do
    dwp = instance_double('DwpMonitor', state: 'offline')
    DwpMonitor.stub(:new).and_return dwp
    sign_in_page.load_page
    sign_in_page.admin_account
  end
  expect(sign_in_page).to have_welcome_user
end

Given("I am not logged in and the benefit checker down") do
  RSpec::Mocks.with_temporary_scope do
    dwp = instance_double('DwpMonitor', state: 'offline')
    DwpMonitor.stub(:new).and_return dwp
    sign_in_page.load_page
    expect(sign_in_page.content).to have_sign_in_title
  end
end

Given("I am not logged in and the benefit checker up") do
  RSpec::Mocks.with_temporary_scope do
    dwp = instance_double('DwpMonitor', state: 'online')
    DwpMonitor.stub(:new).and_return dwp
    sign_in_page.load_page
    expect(sign_in_page.content).to have_sign_in_title
  end
end

When("an admin changes the DWP message to display DWP check is working message") do
  navigation_page.navigation_link.dwp_message.click
  expect(dwp_message_page.content).to have_header
  dwp_message_page.check_online
  expect(dwp_message_page.content).to have_successfully_saved
  navigation_page.go_to_homepage
end

Then("benefits and income based applications can be processed") do
  expect(dashboard_page.content).to have_find_an_application_heading
  expect(dashboard_page).to have_dwp_online_banner
end

Then("I have not signed in") do
  expect(sign_in_page.content).to have_sign_in_title
  expect(sign_in_page.content).to have_sign_in_alert
end

Then("I should see DWP checker is down") do
  expect(benefit_checker_page).to have_dwp_banner_offline
end

Then("I should see DWP checker is up") do
  expect(benefit_checker_page).to have_dwp_banner_online
end

When("the benefit checker is set to offline") do
  DwpWarning.create(check_state: "offline")
  dwp = instance_double('DwpMonitor', state: 'offline')
  DwpMonitor.stub(:new).and_return dwp
end

Then('I should see that the application fails on benefits') do
  expect(confirmation_page.content).to have_reference_number_is
  expect(confirmation_page.content).to have_ineligible
  expect(confirmation_page.content).to have_failed_benefits
end
