Given("I have completed an ineligible paper application - savings too high") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_100
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_between_under_66_ucd
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
  expect(confirmation_page.content).to have_ineligible
end

When("I click on Grant help with fees") do
  confirmation_page.content.wait_until_grant_hwf_visible
  confirmation_page.content.grant_hwf.click
end

When("I click Update application without selecting an option") do
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

Then("I should see an error telling me to select an option") do
  expect(confirmation_page).to have_content(/Please select a reason for granting help with fees/)
end

Then("I should see an error telling me to enter a reason for granting help with fees") do
  expect(confirmation_page).to have_content(/Please enter a reason for granting help with fees/)
end

When("I check the Other option") do
  confirmation_page.content.override.wait_until_other_option_visible
  find(:xpath, './/input[@id="application_value_other"]', visible: false).click
end

When("Click Update application without providing detail") do
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

When("Click Update application after providing detail") do
  confirmation_page.content.override.wait_until_other_reason_textbox_visible
  confirmation_page.content.override.other_reason_textbox.set 'Reason'
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

Then("The application should remain ineligible") do
  expect(confirmation_page.content).to have_ineligible
end

Then("The application should become eligible") do
  expect(confirmation_page.content).to have_granted_hwf
end

When("I Click Update application") do
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

Then("I should see a message telling me the application passed by manager's decision") do
  expect(confirmation_page.content).to have_passed_by_manager
end

When("I check the Paper evidence option") do
  confirmation_page.content.override.wait_until_paper_evidence_option_visible
  confirmation_page.content.override.paper_evidence_option.click
end

Then("I should not see a message telling me the application passed by manager's decision") do
  expect(confirmation_page.content).not_to have_passed_by_manager
end

Given("I have completed an ineligible paper application - income too high") do
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_100
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(children_page.content).to have_header
  children_page.no_children
  expect(income_kind_applicant_page.content).to have_header
  income_kind_applicant_page.submit_wages
  incomes_page.submit_incomes_2000_ucd
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
  complete_processing
  expect(confirmation_page.content).to have_ineligible
end

And("I check the delivery manager option") do
  confirmation_page.content.override.wait_until_other_option_visible
  confirmation_page.content.override.delivery_manager_option.click
end

And("I check the DWP option") do
  confirmation_page.content.override.wait_until_other_option_visible
  confirmation_page.content.override.delivery_manager_option.click
end

And("I should not be able to grant help with fees") do
  expect(confirmation_page.content).not_to have_grant_hwf
end
