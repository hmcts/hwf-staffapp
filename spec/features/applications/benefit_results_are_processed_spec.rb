# coding: utf-8

require 'rails_helper'

RSpec.feature 'Benefit results are processed' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:applicant) { application.applicant }
  let(:application) { create(:application, :applicant_full, ni_number: ni_number, office: office, user: user, benefits: true) }

  let(:dwp_result) { nil }
  let(:dwp_status) { 200 }

  context 'when user selects yes to benefits' do
    before do
      login_as user
      visit application_benefits_path(application)
      choose 'application_benefits_true'
      click_button 'Next'
    end

    context 'the benefits override page is rendered with an error message' do
      let(:ni_number) { Settings.dwp_mock.ni_number_undetermined.first }

      scenario 'the page is rendered with message prompting to fill all details' do
        expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
        expect(page).to have_content('There’s a problem with the applicant’s surname, date of birth or National Insurance number.')
      end
    end

    context 'when all required fields for dwp check have been provided' do
      let(:ni_number) { Settings.dwp_mock.ni_number_yes.first }

      context 'the result is yes' do
        let(:dwp_result) { 'yes' }

        scenario 'the summary page is rendered' do
          choose 'Applicant'
          click_button 'Next'
          expect(page).to have_xpath('//h1', text: 'Check details')
        end
      end

      context 'the result is no' do
        let(:ni_number) { Settings.dwp_mock.ni_number_no.first }

        scenario 'the benefits override page is rendered' do
          expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
        end
      end

      context 'the result is bad request' do
        let(:ni_number) { Settings.dwp_mock.ni_number_dwp_error.first }

        scenario 'the benefits override page is rendered with an error message' do
          expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
          choose 'benefit_override_evidence_false'
          click_button 'Next'
          expect(page).to have_xpath('//h1', text: 'Find an application')
          expect(page).to have_content('Processing benefit applications without paper evidence is not working at the moment. Try again later when the DWP checker is available.')
        end
      end

      context 'the result is undetermined' do
        let(:ni_number) { Settings.dwp_mock.ni_number_undetermined.first }

        scenario 'the benefits override page is rendered with an error message' do
          expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
          expect(page).to have_content('There’s a problem with the applicant’s surname, date of birth or National Insurance number.')
        end
      end

      context 'the result is unspecified error' do
        let(:ni_number) { Settings.dwp_mock.ni_number_500_error.first }

        scenario 'the benefits override page is rendered with an error message' do
          expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
          expect(page).to have_content('You will only be able to process this application if you have supporting evidence that the applicant is receiving benefits')
        end
      end
    end
  end
end
