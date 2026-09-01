require 'rails_helper'

# Feature coverage for docs/benefit_checker_flow.md - online (digital) flow.
# Fast: rack_test only (no JS). The mocked DWP client (FAKE_BENEFIT_CHECK)
# picks the benefit check result from the application's NI number.

# rubocop:disable RSpec/NoExpectationExample
RSpec.feature 'Benefit checker flow - online application' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let!(:jurisdictions) { create_list(:jurisdiction, 1) }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions.first.id, office: office) }

  before do
    login_as user
  end

  # Scenario comments follow the docs/benefit_checker_flow.md columns:
  # | DWP Monitor | DWP State | Run BC Check | BC Outcome | Paper Display | Paper Answer | Outcome |
  # Monitor "any" = not stubbed (resolves to online here); DWP State "Auto" = no DwpWarning record.

  # | any | Auto | yes | Yes | no | - | full |
  scenario 'DWP says Yes: no evidence page, straight to the summary' do
    process_online_application(ni_number: Settings.dwp_mock.ni_number_yes.first)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | No | yes | yes | full |
  scenario 'DWP says No, paper evidence provided' do
    process_online_application(ni_number: Settings.dwp_mock.ni_number_no.first)
    answer_online_evidence(provided: true)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | No | yes | no | none |
  scenario 'DWP says No, no paper evidence' do
    process_online_application(ni_number: Settings.dwp_mock.ni_number_no.first)
    answer_online_evidence(provided: false)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | InvalidRequest | yes | no | none | (rst-8513: not an outage, never blocks)
  scenario 'DWP rejects the applicant data (InvalidRequest), no paper evidence' do
    process_online_application(ni_number: Settings.dwp_mock.surname_dwp_error.first)
    answer_online_evidence(provided: false)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | outage error | yes | yes | full |
  scenario 'DWP outage error, paper evidence provided' do
    process_online_application(ni_number: Settings.dwp_mock.ni_number_dwp_error.first)
    answer_online_evidence(provided: true)
    then_summary_page_is_displayed
  end

  # | any | Auto | yes | outage error | yes | no | redirect to homepage |
  scenario 'DWP outage error, no paper evidence' do
    process_online_application(ni_number: Settings.dwp_mock.ni_number_dwp_error.first)
    answer_online_evidence(provided: false)
    then_user_is_sent_home_with_cannot_process_alert
  end

  # | any | offline | no | - (no check run) | yes | no | none |
  scenario 'admin sets DWP offline: no check is run and "no evidence" still processes' do
    create(:dwp_warning, check_state: DwpWarning::STATES[:offline])
    process_online_application(ni_number: Settings.dwp_mock.ni_number_yes.first)
    expect(page).to have_text('DWP evidence check is disabled')
    expect(BenefitCheck.count).to eq(0)
    answer_online_evidence(provided: false)
    then_summary_page_is_displayed
  end

  # | offline | Auto | yes | Yes | no | - | full | (monitor never stops the check - same as paper)
  scenario 'monitor computes offline on Auto: the check still runs' do
    allow(DwpMonitor).to receive(:new).and_return(instance_double(DwpMonitor, state: 'offline'))
    process_online_application(ni_number: Settings.dwp_mock.ni_number_yes.first)
    expect(BenefitCheck.count).to eq(1)
    then_summary_page_is_displayed
  end

  private

  # Fills the application details form and submits; the benefit check runs on
  # submit and decides whether the Evidence of benefits page is shown.
  def process_online_application(ni_number:)
    online_application = create(:online_application, :with_reference, :benefits, :completed,
                                ni_number: ni_number, jurisdiction: jurisdictions.first)
    visit "/online_applications/#{online_application.id}/edit"
    fill_application_details
    click_button 'Next'
  end

  def fill_application_details
    date_received = Time.zone.today
    fill_in 'online_application_fee', with: 300
    choose "online_application_jurisdiction_id_#{jurisdictions.first.id}"
    fill_in 'online_application_day_date_received', with: date_received.day
    fill_in 'online_application_month_date_received', with: date_received.month
    fill_in 'online_application_year_date_received', with: date_received.year
    fill_in 'online_application_form_name', with: 'E45'
  end

  def answer_online_evidence(provided:)
    expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
    choose provided ? 'online_application_benefits_override_true' : 'online_application_benefits_override_false'
    click_button 'Next'
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
