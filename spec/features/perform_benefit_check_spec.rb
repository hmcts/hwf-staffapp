require 'rails_helper'

RSpec.feature 'Undertake benefit check', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)          { FactoryGirl.create :user }

  context 'as user' do
    scenario 'generates a result page' do

      login_as user
      visit new_dwp_checks_path

      fill_in 'dwp_check_last_name', with: 'bruce'
      fill_in 'dwp_check_dob', with: '01/01/2001'
      fill_in 'dwp_check_ni_number', with: 'AB123456A'
      click_button 'Check'

      expect(page).to have_css('div.dwp-value', text: 'AB123456A', count: 1)
      expect(page).to have_css('div.callout > span.number', text: /benefits/, count: 1)
    end
  end
end
