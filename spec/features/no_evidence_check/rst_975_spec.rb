require 'rails_helper'

RSpec.feature 'Application is not evidence checked when above saving threshold', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  context 'Non-refund application no evidence check for 10th application' do
    let(:application) { create :application_full_remission }

  before do
      create_list :application_full_remission, 9
  end

    scenario 'Every 10th application is not evidence check when saving threshold exceeded' do
		    start_new_application

        expect(page).to have_text 'Personal details'
        fill_in 'Title', with: 'Mr.'
        fill_in 'First and middle names', with: 'Johny'
        fill_in 'Last name', with: 'Mules'
        fill_in 'Date of birth', with: '01/01/1950'
        fill_in 'National Insurance number', with: 'SN876543A'
        choose 'Single'
        click_button 'Next'

		    fill_application_details
		    fill_saving_exceeded_over_61

		    click_button "Complete processing"

      expect(page).to_not have_content('Evidence of income needs to be checked for this application')
      expect(page).to have_content('✗   Not eligible for help with fees')
    end
  end

  context 'Refund application no evidence check for emergency 2nd application' do
    let(:application) { create :application_full_remission, :refund }

    before do
      create_list :application_full_remission, 1, :refund
    end

    scenario 'Every 2nd application is not evidence check when saving threshold exceeded' do
       start_new_application
		fill_personal_details
    fill_application_refund_details
		fill_saving_above_threshold

		click_button "Complete processing"

      expect(page).to_not have_content('Evidence of income needs to be checked for this application')
	    expect(page).to have_content('✗   Not eligible for help with fees')
    end

  context 'Duplicate NINO emergency appliation' do
	   let(:application) { create :application_full_remission }

	scenario 'No evidence check on duplicate NINO when saving threshold is exceeded' do
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

		click_button "Start now"
		fill_personal_details('SN123456D')
		fill_application_details
		fill_saving_above_threshold

		click_button 'Complete processing'

		    expect(page).to_not have_content('Evidence of income needs to be checked for this application')
		    expect(page).to have_content('✗   Not eligible for help with fees')

	    end
   end
  end
end
