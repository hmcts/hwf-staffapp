require 'rails_helper'

RSpec.feature 'Application outside of 3 month limit is not evidence checked when discretion is no', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  context 'Refund application outside 3 month limit' do
    let(:application) { create :application_full_remission, :refund }

    before do
      create_list :application_full_remission, 1, :refund
    end

    scenario 'Every 2nd application is not evidence checked when outside 3 month limit' do
      start_new_application
      fill_personal_details
      fill_application_date_set_discretion_no
      click_button 'Complete processing'

      expect(page).not_to have_content('Evidence of income needs to be checked')
      expect(page).to have_content('✗   Not eligible for help with fees')

    end

    context 'Duplicate NINO with previous evidence checked' do

      let(:application) { create :application_full_remission }

      scenario 'No evidence check on duplicate NINO when outside 3 month limit' do

        visit home_index_url

        within '#process-application' do
          expect(page).to have_text('Process application')
          click_button 'Start now'
        end

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
        fill_application_date_set_discretion_no

        click_button 'Complete processing'

        expect(page).not_to have_content('Evidence of income needs to be checked')
        expect(page).to have_content '✗   Not eligible for help with fees'

      end
    end
  end
end
