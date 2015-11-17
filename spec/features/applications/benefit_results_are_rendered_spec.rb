# coding: utf-8
require 'rails_helper'

RSpec.feature 'Benefit Results', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }
  let(:applicant) { create :applicant_with_all_details, ni_number: ni_number }
  let(:application) { create :application, user_id: user.id, applicant: applicant, benefits: true, status: 'benefits_result' }

  context 'as a signed in user' do

    before do
      dwp_api_response 'Yes'
      # FIXME: Remove this and use factories instead
      BenefitCheckRunner.new(application).run
      login_as user
    end

    context 'after user selects yes to benefits' do
      context 'when NI has not been provided' do
        let(:ni_number) { nil }
        let(:error_message) { "The applicant's details could not be checked with the Department for Work and Pensions" }

        scenario 'the page is rendered with message prompting to fill all details' do
          visit application_benefits_path(application)

          choose 'application_benefits_true'
          click_button 'Next'

          expect(page).to have_content error_message
        end
      end

      context 'when all required fields for dwp check have been provided' do
        let(:ni_number) { 'AB123456A' }

        before do
          dwp_api_response 'Yes'

          application.last_benefit_check.update_attributes(dwp_result: 'yes', error_message: nil)
          visit application_benefits_result_path(application)
        end

        scenario 'the correct view is rendered' do
          expect(page).to have_xpath('//h2', text: 'Benefits')
          expect(page).to have_xpath('//div[contains(@class,"callout")]/h3[@class="bold"]')
          expect(page).to have_link('Next', href: application_summary_path(application))
        end

        context 'the result is deceased' do
          before do
            application.last_benefit_check.update_attributes(dwp_result: 'deceased', error_message: nil)
          end

          scenario 'the view is rendered with the correct style' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "deceased")]/h3[@class="bold"]')
          end

          scenario 'the view is rendered with the correct information' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "deceased")]/h3[@class="bold"]', text: I18n.t('benefit_checks.deceased.heading'))
          end
        end

        context 'the result is no' do
          before do
            application.last_benefit_check.update_attributes(dwp_result: 'no', error_message: nil)
          end

          scenario 'the view is rendered with the correct style' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]')
          end

          scenario 'the view is rendered with the correct information' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant is not receiving benefits')
          end
        end

        context 'the result is server unavailable' do
          before do
            application.last_benefit_check.update_attributes(dwp_result: 'server_unavailable', error_message: nil)
          end

          scenario 'the view is rendered with the correct style' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "server_unavailable")]/h3[@class="bold"]')
          end
          scenario 'the view is rendered with the correct information' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "server_unavailable")]/h3[@class="bold"]', text: I18n.t('benefit_checks.server_unavailable.heading'))
          end
        end

        context 'the result is superseded' do
          before do
            application.last_benefit_check.update_attributes(dwp_result: 'superseded', error_message: nil)
          end

          scenario 'the view is rendered with the correct style' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "superseded")]/h3[@class="bold"]')
          end

          scenario 'the view is rendered with the correct information' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "superseded")]/h3[@class="bold"]', text: I18n.t('benefit_checks.superseded.heading'))
          end
        end

        context 'the result is undetermined' do
          before do
            application.last_benefit_check.update_attributes(dwp_result: 'Undetermined', error_message: nil)
            visit application_benefits_result_path(application)
          end

          scenario 'the page content is correctly rendered' do
            # the Next button is rendered
            expect(page).to have_link('Next', href: application_summary_path(application))
            # a link to personal details is rendered
            expect(page).to have_content "The applicant's details could not be checked with the Department for Work and Pensions"
            # the view is rendered with the correct style
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "callout-none")]/h3[@class="bold"]')
          end
        end

        context 'the result is unspecified error' do
          before do
            application.last_benefit_check.update_attributes(dwp_result: 'unspecified_error', error_message: nil)
          end

          scenario 'the view is rendered with the correct style' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "unspecified_error")]/h3[@class="bold"]')
          end
          scenario 'the view is rendered with the correct information' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "unspecified_error")]/h3[@class="bold"]', text: I18n.t('benefit_checks.unspecified_error.heading'))
          end
        end

        context 'the result is yes' do
          before do
            application.last_benefit_check.update_attributes(dwp_result: 'yes', error_message: nil)
          end

          scenario 'the view is rendered with the correct style' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "yes")]/h3[@class="bold"]')
          end
          scenario 'the view is rendered with the correct information' do
            visit application_benefits_result_path(application)
            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "yes")]/h3[@class="bold"]', text: '✓ The applicant is receiving the correct benefits')
          end
        end
      end
    end
  end
end
