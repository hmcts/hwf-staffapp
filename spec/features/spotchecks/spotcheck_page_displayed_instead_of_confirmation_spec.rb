require 'rails_helper'

RSpec.feature 'Spot check page displayed instead of confirmation', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  let(:application) { create :application_full_remission }

  context 'when the Spotcheck feature is enabled' do
    enable_spotcheck

    scenario 'User continues from the summary page when building the application and is redirected to spot check' do
      create_list :application_full_remission, 9

      visit application_build_path(application_id: application.id, id: 'income_result')

      click_button 'Next'
      click_button 'Continue'

      expect(spotcheck_rendered?).to be true
    end

    scenario 'User tries to display confirmation page directly and is redirected to spot check' do
      create :spotcheck, application: application

      visit application_build_path(application_id: application.id, id: 'confirmation')

      expect(spotcheck_rendered?).to be true
    end
  end

  context 'when the Spotcheck feature is disabled' do
    disable_spotcheck

    scenario 'User continues from the summary page when building the application and lands on confirmation page' do
      create_list :application_full_remission, 9

      visit application_build_path(application_id: application.id, id: 'income_result')

      click_button 'Next'
      click_button 'Continue'

      expect(confirmation_rendered?).to be true
    end

    scenario 'User tries to display confirmation page directly and the confirmation page is displayed' do
      create :spotcheck, application: application

      visit application_build_path(application_id: application.id, id: 'confirmation')

      expect(confirmation_rendered?).to be true
    end
  end

  def confirmation_rendered?
    (%r{\/applications/#{application.id}/build/confirmation}) != nil
  end

  def spotcheck_rendered?
    (%r{\/spotchecks\/#{application.spotcheck.id}} =~ page.current_url) != nil
  end
end
