require 'rails_helper'

RSpec.feature 'Undertake benefit check', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)          { create :user }

  context 'as user' do

    context 'with valid data' do
      before do
        json = '{"original_client_ref": "unique", "benefit_checker_status": "Yes",
                 "confirmation_ref": "T1426267181940",
                 "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
          to_return(status: 200, body: json, headers: {})
      end

      scenario 'generates a result page' do

        login_as user
        visit new_dwp_checks_path

        fill_in 'dwp_check_last_name', with: 'bruce'
        fill_in 'dwp_check_dob', with: '01/01/1980'
        fill_in 'dwp_check_ni_number', with: 'AB123456A'
        click_button 'Check'

        expect(page).to have_xpath('//div', text: 'AB123456A')
        expect(page).to have_xpath('//h3[contains(@class, "bold")]', text: /[Bb]enefits/)
      end
    end
    context 'with invalid data' do
      scenario 'returns to input page' do
        login_as user
        visit new_dwp_checks_path

        fill_in 'dwp_check_last_name', with: 'bruce'
        fill_in 'dwp_check_dob', with: '01/01/2001'
        fill_in 'dwp_check_ni_number', with: 'AB123'
        click_button 'Check'
        expect(page).to have_xpath('//label[@class="error"]', text: I18n.t('activerecord.errors.models.dwp_check.attributes.ni_number.invalid'))
        expect(page).to have_xpath('//input[@type="text"][@value="AB123"]')
      end
    end
  end
end
