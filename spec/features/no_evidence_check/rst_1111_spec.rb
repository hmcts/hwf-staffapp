require 'rails_helper'

RSpec.feature 'EV Skipped for All Benefit Application', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:dwp_result) { nil }
  let(:dwp_status) { 200 }

  before do
    login_as user
    dwp_api_response(dwp_result, dwp_status)
  end

  context 'DWP outcome is Undetermined' do
    let(:dwp_result) { 'Undetermined' }
    let(:application) { create :application_full_remission }

    before do
      create_list :application_full_remission, 9
    end

    scenario 'Benefit application skipped from ev check when dwp is undertermined' do
      start_new_application

      fill_personal_details
      fill_application_details
      fill_saving_and_investment
      fill_benefits(true)
      fill_benefit_evidence(paper_provided: true)

      click_button 'Complete processing'

      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')
    end
  end

  context 'DWP outcome is pass' do
    let(:dwp_result) { 'Yes' }
    let(:application) { create :application_full_remission }

    before do
      create_list :application_full_remission, 9
    end

    scenario 'Benefit application skipped from ev check when dwp is pass' do
      start_new_application

      fill_personal_details
      fill_application_details
      fill_saving_and_investment
      fill_benefits(true)

      click_button 'Complete processing'
      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')
    end
  end

  context 'DWP Outcome is pass and paper evidence is true' do
    let(:dwp_result) { 'Yes' }
    let(:application) { create :application_full_remission, :refund }

    before do
      create_list :application_full_remission, 1, :refund
    end

    scenario 'Benefit application skipped from ev check when dwp is pass and paper evidence confirmed' do
      start_new_application

      fill_personal_details
      fill_application_refund_details
      fill_saving_and_investment
      fill_benefits(true)

      click_button 'Complete processing'

      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')
    end
  end

  context 'DWP Outcome is ECONNREFUSED' do
    let(:dwp_result) { 'Server unavailable' }
    let(:application) { create :application_full_remission, :refund }

    before do
      create_list :application_full_remission, 1, :refund
    end

    scenario 'Every 2nd application is not evidence check when paper evidence is false on Benefit Application' do
      start_new_application

      fill_personal_details
      fill_application_refund_details
      fill_saving_and_investment
      fill_benefits(true)
      fill_benefit_evidence(paper_provided: false)

      click_button 'Complete processing'

      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✗   Not eligible for help with fees')
    end
  end

  context 'DWP Outcome is Yes for emergency application' do
    let(:dwp_result) { 'Yes' }
    let(:application) { create :application_full_remission, :refund }

    before do
      create_list :application_full_remission, 1, :refund
    end

    scenario 'No evidence check on emergency applications' do
      start_new_application

      fill_personal_details
      fill_application_emergency_details
      fill_saving_and_investment
      fill_benefits(true)

      click_button 'Complete processing'

      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')
    end
  end
end
