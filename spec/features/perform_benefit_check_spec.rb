require 'rails_helper'

RSpec.feature 'Undertake benefit check', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)          { FactoryGirl.create :user }

  context 'as user' do

    context 'with valid data' do
      before do
        json = '{"original_client_ref": "unique", "benefit_checker_status": "Yes",
                 "confirmation_ref": "T1426267181940",
                 "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
          with(body: { 'birth_date': '19800101', 'entitlement_check_date': '20150319', 'ni_number': 'AB123456A', 'surname': 'BRUCE' }).
          to_return(status: 200, body: json, headers: {})
      end

      scenario 'generates a result page' do

        login_as user
        visit new_dwp_checks_path

        fill_in 'dwp_check_last_name', with: 'bruce'
        fill_in 'dwp_check_dob', with: '01/01/1980'
        fill_in 'dwp_check_ni_number', with: 'AB123456A'
        click_button 'Check'

        expect(page).to have_css('div.dwp-value', text: 'AB123456A', count: 1)
        expect(page).to have_css('div.callout > span.number', text: /[Bb]enefits/, count: 1)
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
        expect(page).to have_css('div#error_explanation > h3', text: /1 error prevented/, count: 1)
        expect(page).to have_selector('input[type="text"][value="AB123"]')
      end
    end
  end
end
