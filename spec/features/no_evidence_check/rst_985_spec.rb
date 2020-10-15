require 'rails_helper'

RSpec.feature 'Application is not evidence check when income is above threshold', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: office, jurisdiction: jurisdiction }
  let(:office) { create :office, jurisdictions: [jurisdiction] }
  let(:jurisdiction) { create :jurisdiction }

  before do
    login_as user
  end

  context 'Always apply EV check for application with same NINO' do

    let(:application) { create :application_full_remission }

    scenario 'Check that evidence check is on for 2nd and 3rd application with same NINO' do
      start_new_application
      fill_personal_details('SN123456D')
      fill_application_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)
      expect(page).to have_text 'Check details'
      click_button 'Complete processing'

      visit home_index_url
      create_flag_check('SN123456D')

      click_button 'Start now'
      fill_personal_details('SN123456D')
      fill_application_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)
      click_button 'Complete processing'
      expect(page).to have_content('Evidence of income needs to be checked')
      expect(page).not_to have_content('✓ Eligible for help with fees')

      visit home_index_url

      click_button 'Start now'
      fill_personal_details('SN123456D')
      fill_application_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)
      click_button 'Complete processing'
      expect(page).to have_content('Evidence of income needs to be checked')
      expect(page).not_to have_content('✓ Eligible for help with fees')
    end
  end

  context 'Check that every consecutive application with same NINO will be flagged until evidence is provided' do
    let(:application1) { create :application, :waiting_for_evidence_state, applicant: applicant1, office: office }
    let(:application2) { create :application, :waiting_for_evidence_state, applicant: applicant2, office: office }
    let(:applicant1) { create :applicant_with_all_details, ni_number: 'AB123456D' }
    let(:applicant2) { create :applicant_with_all_details, ni_number: 'AB123456D' }

    before do
      application1
      application2
    end

    scenario 'finishing EV check and creating new application with same NINO' do
      visit evidence_checks_path
      within(:css, '.waiting-for-evidence') do
        expect(page).to have_content(application1.reference)
        expect(page).to have_content(application2.reference)
      end

      click_link application1.reference
      expect(page).to have_text "#{application1.reference} - Waiting for evidence"

      click_link 'Start now'
      choose 'Yes, the evidence is for the correct applicant and covers the correct time period'
      click_button 'Next'

      fill_in :evidence_income, with: application1.income
      click_button 'Next'
      click_link 'Next'
      click_button 'Complete processing'
      expect(page).to have_content('Processing complete')

      visit evidence_checks_path
      within(:css, '.waiting-for-evidence') do
        expect(page).not_to have_content(application1.reference)
        expect(page).to have_content(application2.reference)
      end

      visit home_index_path

      click_button 'Start now'
      fill_personal_details('AB123456D')
      fill_application_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)
      click_button 'Complete processing'

      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')
    end
  end

  context 'Duplicate NINO not included in 1 in 2 count for Refund application' do
    let(:application) { create :application_full_remission, :refund }

    before do
      create_list :application_full_remission, 1, :refund
    end

    scenario 'Create duplicate NINO and verify it is not included in 1 in 2 count' do
      start_new_application
      fill_personal_details('SN987654D')
      fill_application_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)
      expect(page).to have_text 'Check details'
      click_button 'Complete processing'
      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')

      visit home_index_url
      create_flag_check('SN987654D')

      click_button 'Start now'
      fill_personal_details('SN987654D')
      fill_application_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)
      click_button 'Complete processing'
      expect(page).to have_content('Evidence of income needs to be checked')
      expect(page).not_to have_content('✓ Eligible for help with fees')

      start_new_application
      fill_personal_details
      fill_application_refund_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)
      click_button 'Complete processing'
      expect(page).to have_content('Evidence of income needs to be checked')
      expect(page).not_to have_content('✓ Eligible for help with fees')
    end
  end
end
