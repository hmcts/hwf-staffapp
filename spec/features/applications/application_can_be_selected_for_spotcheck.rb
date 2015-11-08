require 'rails_helper'

RSpec.feature 'Application can be selected for evidence check', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  context 'Non-refund application' do
    let(:application) { create :application_full_remission }

    before do
      create_list :application_full_remission, 9
    end

    scenario 'Every 10th application is selected for evidence check' do
      visit application_income_path(application)

      click_button 'Next'
      click_button 'Next'

      expect(page).to have_content('Evidence of income needs to be checked for this application')
    end
  end

  context 'Refund application' do
    let(:application) { create :application_full_remission, :refund }

    before do
      create_list :application_full_remission, 1, :refund
    end

    scenario 'Every 2nd application is selected for evidence check' do
      visit application_income_path(application)

      click_button 'Next'
      click_button 'Next'

      expect(page).to have_content('Evidence of income needs to be checked for this application')
    end
  end
end
