# coding: utf-8
require 'rails_helper'

RSpec.feature 'Benefit results are processed', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:applicant) { create :applicant_with_all_details, ni_number: ni_number }
  let(:application) { create :application, office: office, user_id: user.id, applicant: applicant, benefits: true }

  let(:dwp_result) { nil }
  let(:dwp_status) { 200 }

  context 'when user selects yes to benefits' do
    before do
      login_as user

      dwp_api_response(dwp_result, dwp_status)

      visit application_benefits_path(application)
      choose 'application_benefits_true'
      click_button 'Next'
    end

    context 'the benefits override page is rendered with an error message' do
      let(:ni_number) { nil }

      scenario 'the page is rendered with message prompting to fill all details' do
        expect(page).to have_xpath('//h2', text: 'Benefits')
        expect(page).to have_content('There’s a problem with the applicant’s surname, date of birth or National Insurance number.')
      end
    end

    context 'when all required fields for dwp check have been provided' do
      let(:ni_number) { 'AB123456A' }

      context 'the result is yes' do
        let(:dwp_result) { 'yes' }

        scenario 'the summary page is rendered' do
          expect(page).to have_xpath('//h2', text: 'Check details')
        end
      end

      context 'the result is deceased' do
        let(:dwp_result) { 'deceased' }

        scenario 'the summary page is rendered' do
          expect(page).to have_xpath('//h2', text: 'Check details')
        end
      end

      context 'the result is no' do
        let(:dwp_result) { 'no' }

        scenario 'the benefits override page is rendered' do
          expect(page).to have_xpath('//h2', text: 'Benefits')
        end
      end

      context 'the result is server unavailable' do
        let(:dwp_result) { 'server unavailable' }
        let(:dwp_status) { 500 }

        scenario 'the benefits override page is rendered with an error message' do
          expect(page).to have_xpath('//h2', text: 'Benefits')
          expect(page).to have_content('You will only be able to process this application if you have paper evidence that the applicant is receiving benefits')
        end
      end

      context 'the result is superseded' do
        let(:dwp_result) { 'superseded' }

        scenario 'the summary page is rendered' do
          expect(page).to have_xpath('//h2', text: 'Check details')
        end
      end

      context 'the result is undetermined' do
        let(:dwp_result) { 'undetermined' }

        scenario 'the benefits override page is rendered with an error message' do
          expect(page).to have_xpath('//h2', text: 'Benefits')
          expect(page).to have_content('There’s a problem with the applicant’s surname, date of birth or National Insurance number.')
        end
      end

      context 'the result is unspecified error' do
        let(:dwp_result) { 'unspecified error' }

        scenario 'the benefits override page is rendered with an error message' do
          expect(page).to have_xpath('//h2', text: 'Benefits')
          expect(page).to have_content('You will only be able to process this application if you have paper evidence that the applicant is receiving benefits')
        end
      end
    end
  end
end
