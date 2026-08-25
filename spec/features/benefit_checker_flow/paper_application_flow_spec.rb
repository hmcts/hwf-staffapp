require 'rails_helper'

# Feature coverage for docs/benefit_checker_flow.md - paper flow.
# Fast: rack_test only (no JS). The mocked DWP client (FAKE_BENEFIT_CHECK)
# picks the benefit check result from the applicant's NI number.

# rubocop:disable RSpec/NoExpectationExample
RSpec.feature 'Benefit checker flow - paper application' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let!(:jurisdictions) { create_list(:jurisdiction, 1) }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions.first.id, office: office) }

  before do
    login_as user
    start_new_application
  end

  # Scenario comments follow the docs/benefit_checker_flow.md columns:
  # | DWP Monitor | DWP State | Run BC Check | BC Outcome | Paper Display | Paper Answer | Outcome |
  # Monitor "any" = not stubbed (resolves to online here); DWP State "Auto" = no DwpWarning record.

  # | any | Auto | yes | Yes | no | - | full |
  scenario 'DWP says Yes: no evidence page, straight to declaration' do
    drive_to_benefits_question(ni_number: Settings.dwp_mock.ni_number_yes.first)
    answer_on_benefits_yes
    then_declaration_page_is_displayed
  end

  # | any | Auto | yes | No | yes | yes | full |
  scenario 'DWP says No, paper evidence provided' do
    drive_to_benefits_question(ni_number: Settings.dwp_mock.ni_number_no.first)
    answer_on_benefits_yes
    answer_paper_evidence(provided: true)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | No | yes | no | none |
  scenario 'DWP says No, no paper evidence' do
    drive_to_benefits_question(ni_number: Settings.dwp_mock.ni_number_no.first)
    answer_on_benefits_yes
    answer_paper_evidence(provided: false)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | InvalidRequest | yes | yes | full |
  scenario 'DWP rejects the applicant data (InvalidRequest), paper evidence provided' do
    drive_to_benefits_question(ni_number: Settings.dwp_mock.surname_dwp_error.first)
    answer_on_benefits_yes
    answer_paper_evidence(provided: true)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | InvalidRequest | yes | no | none | (rst-8513: not an outage, never blocks)
  scenario 'DWP rejects the applicant data (InvalidRequest), no paper evidence' do
    drive_to_benefits_question(ni_number: Settings.dwp_mock.surname_dwp_error.first)
    answer_on_benefits_yes
    answer_paper_evidence(provided: false)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | outage error | yes | yes | full |
  scenario 'DWP outage error, paper evidence provided' do
    drive_to_benefits_question(ni_number: Settings.dwp_mock.ni_number_dwp_error.first)
    answer_on_benefits_yes
    answer_paper_evidence(provided: true)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | outage error | yes | no | redirect to homepage |
  scenario 'DWP outage error, no paper evidence' do
    drive_to_benefits_question(ni_number: Settings.dwp_mock.ni_number_dwp_error.first)
    answer_on_benefits_yes
    answer_paper_evidence(provided: false)
    then_user_is_sent_home_with_cannot_process_alert
  end

  # | any | offline | no | - (no check run) | yes | no | none |
  scenario 'admin sets DWP offline: no check is run and "no evidence" still processes' do
    create(:dwp_warning, check_state: DwpWarning::STATES[:offline])
    drive_to_benefits_question(ni_number: Settings.dwp_mock.ni_number_yes.first)
    answer_on_benefits_yes
    expect(BenefitCheck.count).to eq(0)
    answer_paper_evidence(provided: false)
    then_summary_page_is_displayed
  end

  # | offline | Auto | yes | Yes | no | - | full | (banner only - monitor never stops the check)
  scenario 'monitor computes offline on Auto: banner shows but the check still runs' do
    allow(DwpMonitor).to receive(:new).and_return(instance_double(DwpMonitor, state: 'offline'))
    drive_to_benefits_question(ni_number: Settings.dwp_mock.ni_number_yes.first)
    expect(page).to have_text('You will only be able to process this application if you have supporting evidence')
    answer_on_benefits_yes
    expect(BenefitCheck.count).to eq(1)
    then_declaration_page_is_displayed
  end

  private

  # Ends on the "Benefits the applicant is receiving" question page
  def drive_to_benefits_question(ni_number:)
    fill_personal_details(ni_number)
    fill_application_details
    choose 'application_min_threshold_exceeded_false'
    click_button 'Next'
  end

  def fill_personal_details(ni_number)
    dob = Time.zone.today - 25.years
    fill_in 'application_first_name', with: 'Peter'
    fill_in 'application_last_name', with: 'Smith'
    fill_in 'application_day_date_of_birth', with: dob.day
    fill_in 'application_month_date_of_birth', with: dob.month
    fill_in 'application_year_date_of_birth', with: dob.year
    fill_in 'application_ni_number', with: ni_number
    choose 'application_married_false'
    click_button 'Next'
  end

  def fill_application_details
    date_received = Time.zone.yesterday
    fill_in 'application_fee', with: 410
    find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
    fill_in 'application_day_date_received', with: date_received.day
    fill_in 'application_month_date_received', with: date_received.month
    fill_in 'application_year_date_received', with: date_received.year
    fill_in 'Form number', with: 'ABC123'
    click_button 'Next'
  end

  def answer_on_benefits_yes
    choose 'application_benefits_true'
    click_button 'Next'
  end

  def answer_paper_evidence(provided:)
    expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
    choose provided ? 'benefit_override_evidence_true' : 'benefit_override_evidence_false'
    click_button 'Next'
  end

  def then_declaration_page_is_displayed
    expect(page).to have_text('Declaration and statement of truth')
  end

  def then_summary_page_is_displayed
    expect(page).to have_xpath('//h1', text: 'Check details')
  end

  def then_user_is_sent_home_with_cannot_process_alert
    expect(page).to have_xpath('//h1', text: 'Find an application')
    expect(page).to have_text('Processing benefit applications without paper evidence is not working at the moment')
  end
end
# rubocop:enable RSpec/NoExpectationExample
