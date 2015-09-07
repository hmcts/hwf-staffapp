require 'rails_helper'

RSpec.feature 'Application can be selected for spotcheck', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  context 'Non-refund application' do
    let(:application) { create :income_based_application }

    before do
      create_list :income_based_application, 9
    end

    scenario 'Every 10th application is selected for spotcheck' do
      visit application_build_path(application_id: application.id, id: 'income_result')

      click_button 'Next'

      expect(page).to have_content('This application has been chosen for investigation.')
    end
  end

  context 'Refund application' do
    let(:application) { create :income_based_application, :refund }

    before do
      create_list :income_based_application, 1, :refund
    end

    scenario 'Every 2nd application is selected for spotcheck' do
      visit application_build_path(application_id: application.id, id: 'income_result')

      click_button 'Next'

      expect(page).to have_content('This application has been chosen for investigation.')
    end
  end
end
