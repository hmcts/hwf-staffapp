BAD_REQUEST = 400

Given("There are no applications pending") do
  # Empty step do nothing
end

Given("There is an application pending") do
  @current_user = FactoryBot.create(:user)
  @applicant = create_application_with_bad_request_result_with(@current_user)
end

Given("There are 2 applications that have been submitted and pending for different offices") do
  @current_user = FactoryBot.create(:user)
  @applicant = create_application_with_bad_request_result_with(@current_user)

  create_application_with_bad_request_result_with(FactoryBot.create(:user))
end

Given("the applicant has no records of benefits with DWP") do
  online_application = OnlineApplication.find_by(reference: 'HWF-ABC-123')
  online_application.update(ni_number: Settings.dwp_mock.ni_number_no.last)
end

Given("the applicant will fail DWP call") do
  online_application = OnlineApplication.find_by(reference: 'HWF-ABC-123')
  online_application.update(ni_number: Settings.dwp_mock.ni_number_dwp_error.last)
end

Given("I am a staff member and I process an online benefit application") do
  create_online_application('HWF-ABC-123')
  user = FactoryBot.create(:user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page.content).to have_find_an_application_heading
  reference = 'HWF-ABC-123'
  dashboard_page.content.online_search_reference.set reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.content.look_up_button.click
end

Given("I'm on the Check details page") do
  expect(application_details_page.content).to have_header
  application_details_page.content.jurisdiction.click
  click_button 'Next', visible: false
  expect(summary_page.content).to have_header
end

Given("I am a staff member and I process a paper-based benefit application") do
  user = FactoryBot.create(:user)
  sign_in_page.load_page
  sign_in_page.sign_in_with(user)
  expect(dashboard_page).to have_welcome_user
  dashboard_page.process_application
end

Given("I'm on the 'Benefits the applicant is receiving page'") do
  personal_details_page.submit_all_personal_details_ni_with_dwp_error_benefits
  application_details_page.submit_fee_600
  savings_investments_page.submit_less_than

  expect(benefits_page.content).to have_benefit_question
end

Given("I answer 'Yes' to 'Is the applicant receiving one of these benefits?' question") do
  benefits_page.content.yes.click
end

Given('I answer no and press Next') do
  paper_evidence_page.submit_evidence_no
end

Given("I am a staff member at the home page") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('online')

    user = @current_user || FactoryBot.create(:user)
    sign_in_page.load_page
    sign_in_page.sign_in_with(user)

    expect(dashboard_page).to have_welcome_user
    expect(dashboard_page).to have_dwp_online_banner
  end
end

Given("I am a staff member at the 'Pending benefit applications' page with the DWP checker online") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('online')

    sign_in_page.load_page
    sign_in_page.sign_in_with(@current_user)
    expect(dashboard_page).to have_welcome_user
    expect(dashboard_page).to have_dwp_online_banner

    expect(dashboard_page.content).to have_process_when_back_online_heading
    expect(dashboard_page.content).to have_pending_applications_link
    go_to_pending_applications
  end
end

Given("I am a staff member at the 'Pending benefit applications' page with the DWP checker offline") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('offline')

    sign_in_page.load_page
    sign_in_page.sign_in_with(@current_user)
    expect(dashboard_page).to have_welcome_user
    expect(dashboard_page).to have_dwp_offline_banner

    expect(dashboard_page.content).to have_process_when_back_online_heading
    expect(dashboard_page.content).to have_pending_applications_link
    go_to_pending_applications
  end
end

Given("there is a heading 'Process when DWP is back online'") do
  expect(dashboard_page.content).to have_process_when_back_online_heading
end

Given("I see a link 'Pending applications to be processed' under the heading") do
  expect(dashboard_page.content).to have_pending_applications_link
end

When("I press Complete processing and the DWP response is 'LSCBC959: Service unavailable'") do
  stub_dwp_response_as_dwp_down_request
  complete_processing
end

When("I press 'Next' and the DWP response is 'LSCBC959: Service unavailable'") do
  stub_dwp_response_as_dwp_down_request
  benefits_page.click_button 'Next'
end

When("I click on the application 'Ready to process' link") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('online')
    dwp_failed_applications_page.content.dwp_failed_applications.ready_to_process_link.click
  end
end

When("I click on the application 'Id' link") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('online')
    dwp_failed_applications_page.select_id_link_from_first_row
  end
end

When("I complete processing the application") do
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('online')

    expect(personal_details_page.content).to have_header
    personal_details_page.click_next
    expect(application_details_page.content).to have_header
    application_details_page.content.jurisdiction.click
    application_details_page.click_next
    expect(savings_investments_page.content).to have_header
    application_details_page.click_next
    expect(summary_page.content).to have_header
    complete_processing
  end
end

When("I click on the 'Pending applications to be processed' link") do
  go_to_pending_applications
end

Then("I should be redirected to home page") do
  expect(dashboard_page.content).to have_find_an_application_heading
  WebMock.reset!
  WebMock.allow_net_connect!(net_http_connect_on_start: true, allow_localhost: true)
end

Then("I should see a message that the DWP Checker is not available") do
  expect(dashboard_page.content.alert_title).to have_text 'There is a problem'
  expect(dashboard_page.content.alert_text).to have_text 'Processing benefit applications without paper evidence is not working at the moment. Try again later when the DWP checker is available.'
end

Then("I should see 'Process when DWP is back online' section") do
  expect(dashboard_page.content).to have_process_when_back_online_heading
  expect(dashboard_page.content).to have_pending_applications_link
end

Then("I should not see 'Process when DWP is back online' section") do
  expect(dashboard_page.content).not_to have_process_when_back_online_heading
  expect(dashboard_page.content).not_to have_pending_applications_link
end

Then("On selecting the link I should see the paper-based application I was just processing in a list") do
  go_to_pending_applications

  dwp_failed_applications_rows = dwp_failed_applications_page.table_rows
  expect(dwp_failed_applications_rows.size).to eq(1)
  expect(dwp_failed_applications_rows[0]).to have_content('created')
  expect(dwp_failed_applications_rows[0]).to have_content('John Christopher Smith')
  expect(dwp_failed_applications_rows[0]).to have_content('Not ready to process')
end

Then("On selecting the link I should see the online application I was just processing in a list") do
  go_to_pending_applications
  expect(dwp_failed_applications_page.content).to have_page_header
  dwp_failed_applications_rows = dwp_failed_applications_page.table_rows
  expect(dwp_failed_applications_rows.size).to eq(1)
  expect(dwp_failed_applications_rows[0]).to have_content('created')
  expect(dwp_failed_applications_rows[0]).to have_content('Peter Smith')
  expect(dwp_failed_applications_rows[0]).to have_content('Not ready to process')
end

Then("I should be on the result page with the application status set to processed") do
  expect(evidence_page.content).to have_result
  expect(evidence_page.content.evidence_summary[0].summary_row[0]).to have_text 'Savings and investments ✗ Failed'
end

Then("I should be on the page 'Pending benefit applications'") do
  expect(dwp_failed_applications_page.content).to have_page_header
end

Then("there is an application in the pending list") do
  expect(dwp_failed_applications_page.table_rows.size).to eq(1)
end

Then("I should see subheading 'Process when DWP is back online'") do
  expect(dwp_failed_applications_page.content).to have_sub_heading
end

Then("I see a table view of pending applications") do
  expect(dwp_failed_applications_page.table_rows.size).to eq(1)
end

Then("I should see all the pending application columns for non-admin") do
  column_headings = dwp_failed_applications_page.table_heading
  expect(column_headings[0].text).to eq('Id')
  expect(column_headings[1].text).to eq('Status')
  expect(column_headings[2].text).to eq('Applicant')
  expect(column_headings[3].text).to eq('Last updated')
  expect(column_headings[4].text).to eq('Process by')
  expect(column_headings[6].text).to eq('Ready to process?')
end

Then("I should see all the pending application columns for admin") do
  column_headings = dwp_failed_applications_page.table_heading
  expect(column_headings[0].text).to eq('Id')
  expect(column_headings[1].text).to eq('Status')
  expect(column_headings[2].text).to eq('Applicant')
  expect(column_headings[3].text).to eq('Last updated')
  expect(column_headings[4].text).to eq('Process by')
  expect(column_headings[5].text).to eq('Office')
  expect(column_headings[6].text).to eq('Ready to process?')
end

Then("I should see 'Not ready to process' in red text") do
  expect(dwp_failed_applications_page.content.dwp_failed_applications).to have_not_ready_to_process_text
end

Then("the 'Id' should still be selectable as a link") do
  dwp_failed_applications_page.select_id_link_from_first_row
  expect(personal_details_page.content).to have_header
end

Then("I should only see the application for my office in the pending list") do
  expect(dwp_failed_applications_page.content).to have_page_header
  dwp_failed_applications_rows = dwp_failed_applications_page.table_rows

  expect(dwp_failed_applications_rows.size).to eq(1)
  expect(dwp_failed_applications_rows[0]).to have_content('created')
  expect(dwp_failed_applications_rows[0]).to have_content("#{@applicant.title} #{@applicant.first_name} #{@applicant.last_name}")
  expect(dwp_failed_applications_rows[0]).to have_content('Ready to process')
end

Then("There should be no heading 'Process when DWP is back online'") do
  expect(dashboard_page.content).to have_no_process_when_back_online_heading
end

Then("there should be no link 'Pending applications to be processed'") do
  expect(dashboard_page.content).to have_no_pending_applications_link
end

Given("I am logged in as an admin and there is an application pending") do
  @current_user = FactoryBot.create(:admin)
  @applicant = create_application_with_bad_request_result_with(@current_user)
  RSpec::Mocks.with_temporary_scope do
    dwp_monitor_state_as('online')

    user = @current_user
    sign_in_page.load_page
    sign_in_page.sign_in_with(user)

    expect(dashboard_page).to have_welcome_user
    expect(dashboard_page).to have_dwp_online_banner
  end
end

Then("I should see one application pending") do
  dwp_failed_applications_rows = dwp_failed_applications_page.table_rows
  expect(dwp_failed_applications_rows.size).to eq(1)
  expect(dwp_failed_applications_rows[0]).to have_content("#{@applicant.title} #{@applicant.first_name} #{@applicant.last_name}")
end

When("the applicant has not provided Evidence of benefits") do
  benefit_checker_page.content.no.click
  benefit_checker_page.click_next
end
