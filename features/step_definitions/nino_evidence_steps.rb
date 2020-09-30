Given("I create an application A that waits for evidence") do
  @user1 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state, ni_number: 'AB123456D', office: @user1.office, user: @user1)
end

And("I create an Application B that has correct evidence") do
  @user2 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state, ni_number: 'AB123456D', office: @user2.office, user: @user2)

  sign_in_page.load_page
  fill_in 'Email', with: @user2.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
  dashboard_page.content.waiting_for_evidence_application_link.click
  click_on 'Start now', visible: false
  expect(incomes_page).to have_current_path(%r{/accuracy})
  evidence_accuracy_page.content.correct_evidence.click
  next_page
  expect(incomes_page).to have_current_path(%r{/income})
  fill_in 'Total monthly income from evidence', with: 1000
  next_page
  next_page
  complete_processing

end

When("I create Application C") do
  click_link 'Sign out', visible: false
  @user3 = FactoryBot.create(:user)
  fill_in 'Email', with: @user3.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'

  FactoryBot.create(:online_application, :with_reference, :income1000, ni_number: 'AB123456D')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  click_on 'Look up', visible: false

  process_online_application_page.content.group[1].jurisdiction[0].click
  next_page
  complete_processing
end

When("I create an Application B and wrong evidence is provided") do
  @user2 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state, ni_number: 'AB123456D', office: @user2.office, user: @user2)

  sign_in_page.load_page
  fill_in 'Email', with: @user2.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
  dashboard_page.content.waiting_for_evidence_application_link.click
  click_on 'Start now', visible: false
  expect(incomes_page).to have_current_path(%r{/accuracy})
  evidence_accuracy_page.content.problem_with_evidence.click
  next_page
  expect(incomes_page).to have_current_path(%r{/evidence/accuracy_incorrect_reason/2})
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  next_page
  complete_processing
end

And("evidence check is skipped") do
  expect(process_online_application_page.content.summary_row[2]).to have_text 'Income ✓ Passed'
end

And("evidence check is called") do
  expect(process_online_application_page.content.summary_row[2]).to have_text 'Income Waiting for evidence'
end

And("I close application A") do
  click_link 'Sign out', visible: false
  fill_in 'Email', with: @user1.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'

  dashboard_page.content.waiting_for_evidence_application_link.click
  evidence_page.content.evidence_can_not_be_processed.click
  click_link 'Return application', visible: false
  problem_with_evidence_page.submit_not_arrived_too_late
  click_on 'Finish'
end

Then("I create Application D") do
  click_link 'Sign out', visible: false
  sign_in_as_user
  FactoryBot.create(:online_application, :with_reference, :income1000, ni_number: 'AB123456D')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  click_on 'Look up', visible: false
  process_online_application_page.content.group[1].jurisdiction[0].click
  next_page
  complete_processing
end

When("Application C has correct evidence") do
  click_link 'Sign out', visible: false
  fill_in 'Email', with: @user3.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
  dashboard_page.content.waiting_for_evidence_application_link2.click

  click_on 'Start now', visible: false
  expect(incomes_page).to have_current_path(%r{/accuracy})
  evidence_accuracy_page.content.correct_evidence.click
  next_page
  expect(incomes_page).to have_current_path(%r{/income})
  fill_in 'Total monthly income from evidence', with: 1000
  next_page
  next_page
  complete_processing
end

Then("I create Application E") do
  click_link 'Sign out', visible: false
  sign_in_as_user
  FactoryBot.create(:online_application, :with_reference, :income1000, ni_number: 'AB123456D')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  click_on 'Look up', visible: false
  process_online_application_page.content.group[1].jurisdiction[0].click
  next_page
  complete_processing
end

When("Application A has failed evidence") do
  click_link 'Sign out', visible: false
  fill_in 'Email', with: @user1.email
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
  dashboard_page.content.waiting_for_evidence_application_link.click

  click_on 'Start now', visible: false
  expect(incomes_page).to have_current_path(%r{/accuracy})
  evidence_accuracy_page.content.problem_with_evidence.click
  next_page
  expect(incomes_page).to have_current_path(%r{/evidence/accuracy_incorrect_reason/})
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  next_page
  complete_processing
end

When("Application D has correct evidence") do
  dashboard_page.go_home
  dashboard_page.content.waiting_for_evidence_application_link2.click

  click_on 'Start now', visible: false
  expect(incomes_page).to have_current_path(%r{/accuracy})
  evidence_accuracy_page.content.correct_evidence.click
  next_page
  expect(incomes_page).to have_current_path(%r{/income})
  fill_in 'Total monthly income from evidence', with: 1000
  next_page
  next_page
  complete_processing
end
