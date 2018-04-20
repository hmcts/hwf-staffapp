require 'rails_helper'

RSpec.feature 'Application is not evidence check when income is above threshold', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

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
end
