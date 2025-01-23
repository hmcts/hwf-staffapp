require 'rails_helper'

RSpec.feature 'Application is evidence checked when 1 in X' do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create(:user) }

  before do
    dwp_api_response ''
    login_as user
  end

  context 'Benefit application excluded in the 1 in 10 count' do
    let(:application) { create(:application_full_remission) }

    before do
      create_list(:application_full_remission, 9)
    end

    scenario 'Every 10th application is not evidence check when a benefit application' do
      start_new_application

      fill_personal_details
      fill_application_details
      fill_saving_and_investment
      fill_benefits(true)
      fill_benefit_evidence(paper_provided: true)

      click_button 'Complete processing'

      expect(page).to have_no_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')
    end
  end

  context 'Benefit application with paper evidence false excluded in the 1 in 10 count' do
    let(:application) { create(:application_full_remission) }

    before do
      create_list(:application_full_remission, 9)
    end

    scenario 'Every 10th application is not evidence check when a benefit application paper check is false' do
      start_new_application

      fill_personal_details
      fill_application_details
      fill_saving_and_investment
      fill_benefits(true)
      fill_benefit_evidence(paper_provided: false)

      click_button 'Complete processing'
      expect(page).to have_no_content('Evidence of income needs to be checked')
      expect(page).to have_content('✗   Not eligible for help with fees')
    end
  end

  context 'Benefit application excluded in the 1 in 2 count' do
    let(:application) { create(:application_full_remission, :refund) }

    before do
      create_list(:application_full_remission, 1, :refund)
    end

    scenario 'Every 2nd application is not evidence check when Benefit Application' do
      start_new_application

      fill_personal_details
      fill_application_refund_details
      fill_saving_and_investment
      fill_benefits(true)
      fill_benefit_evidence(paper_provided: true)

      click_button 'Complete processing'

      expect(page).to have_no_content('Evidence of income needs to be checked')
      expect(page).to have_content('✓ Eligible for help with fees')
    end
  end

  context 'Benefit application with papper evidence false excluded in the 1 in 2 count' do
    let(:application) { create(:application_full_remission, :refund) }

    before do
      create_list(:application_full_remission, 1, :refund)
    end

    scenario 'Every 2nd application is not evidence check when paper evidence is false on Benefit Application' do
      start_new_application

      fill_personal_details
      fill_application_refund_details
      fill_saving_and_investment
      fill_benefits(true)
      fill_benefit_evidence(paper_provided: false)

      click_button 'Complete processing'

      expect(page).to have_no_content('Evidence of income needs to be checked')
      expect(page).to have_content('✗   Not eligible for help with fees')
    end
  end

  context 'Income Application within 3 month of application Date' do
    let(:application) { create(:application_full_remission, :refund) }

    before do
      create(:application_full_remission_ev, :refund)
      create(:application_full_remission, :refund)
    end

    scenario 'Every 2nd application is evidence check when application is within 3 month of application date' do
      start_new_application
      fill_personal_details_no_ni
      fill_application_refund_details
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)

      click_button 'Complete processing'
      expect(page).to have_content('Evidence of income needs to be checked')
      expect(page).to have_no_content('✓ Eligible for help with fees')
    end
  end

  context 'Income Application exceeds 3month application and Discretion applied' do
    let(:application) { create(:application_full_remission, :refund) }

    before do
      create(:application_full_remission_ev, :refund)
      create(:application_full_remission, :refund)
    end

    scenario 'Every 2nd application is evidence check when 3 month application date exceeded and discretion is yes' do
      start_new_application
      fill_personal_details
      fill_application_date_set_discretion_yes
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(false)

      click_button 'Complete processing'
      expect(page).to have_content("- For HMRC income checking")
      expect(page).to have_no_content('✓ Eligible for help with fees')
    end
  end
end
