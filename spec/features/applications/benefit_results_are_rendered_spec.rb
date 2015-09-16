require 'rails_helper'

RSpec.feature 'Benefit Results', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }
  let(:application) { create :application, user_id: user.id, ni_number: 'AB123456A', benefits: true, status: 'benefits_result' }
  context 'as a signed in user' do

    before do
      WebMock.disable_net_connect!(allow: 'codeclimate.com')
      dwp_api_response 'Yes'
    end

    before do
      login_as user
    end

    context 'after user selects yes to benefits' do
      before do
        application.last_benefit_check.update_attributes(dwp_result: 'yes', error_message: nil)
        visit application_build_path(application_id: application.id, id: 'benefits_result')
      end

      scenario 'the correct view is rendered' do
        expect(page).to have_xpath('//h2', text: 'Benefits')
        expect(page).to have_xpath('//div[contains(@class,"callout")]/h3[@class="bold"]')
      end

      scenario 'the next button is rendered' do
        expect(page).to have_xpath('//input[@type="submit"]')
      end

      context 'the result is deceased' do
        before do
          application.last_benefit_check.update_attributes(dwp_result: 'deceased', error_message: nil)
        end

        scenario 'the view is rendered with the correct style' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "deceased")]/h3[@class="bold"]')
        end

        scenario 'the view is rendered with the correct information' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "deceased")]/h3[@class="bold"]', text: I18n.t('benefit_checks.deceased.heading'))
        end
      end

      context 'the result is no' do
        before do
          application.last_benefit_check.update_attributes(dwp_result: 'no', error_message: nil)
        end

        scenario 'the view is rendered with the correct style' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]')
        end

        scenario 'the view is rendered with the correct information' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant is not receiving benefits')
        end
      end

      context 'the result is server unavailable' do
        before do
          application.last_benefit_check.update_attributes(dwp_result: 'server_unavailable', error_message: nil)
        end

        scenario 'the view is rendered with the correct style' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "server_unavailable")]/h3[@class="bold"]')
        end
        scenario 'the view is rendered with the correct information' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "server_unavailable")]/h3[@class="bold"]', text: I18n.t('benefit_checks.server_unavailable.heading'))
        end
      end

      context 'the result is superseded' do
        before do
          application.last_benefit_check.update_attributes(dwp_result: 'superseded', error_message: nil)
        end

        scenario 'the view is rendered with the correct style' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "superseded")]/h3[@class="bold"]')
        end

        scenario 'the view is rendered with the correct information' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "superseded")]/h3[@class="bold"]', text: I18n.t('benefit_checks.superseded.heading'))
        end
      end

      context 'the result is undetermined' do
        before do
          application.last_benefit_check.update_attributes(dwp_result: 'Undetermined', error_message: nil)
          visit application_build_path(application_id: application.id, id: 'benefits_result')
        end

        scenario 'the next button is not rendered' do
          expect(page).not_to have_xpath('//input[@type="submit"]')
        end

        scenario 'a link to personal details is rendered' do
          expect(page).to have_xpath('//a', text: 'Check personal details')
        end

        scenario 'the view is rendered with the correct style' do
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "undetermined")]/h3[@class="bold"]')
        end

        scenario 'the view is rendered with the correct information' do
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "undetermined")]/h3[@class="bold"]', text: I18n.t('benefit_checks.undetermined.heading'))
        end
      end

      context 'the result is unspecified error' do
        before do
          application.last_benefit_check.update_attributes(dwp_result: 'unspecified_error', error_message: nil)
        end

        scenario 'the view is rendered with the correct style' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "unspecified_error")]/h3[@class="bold"]')
        end
        scenario 'the view is rendered with the correct information' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "unspecified_error")]/h3[@class="bold"]', text: I18n.t('benefit_checks.unspecified_error.heading'))
        end
      end

      context 'the result is yes' do
        before do
          application.last_benefit_check.update_attributes(dwp_result: 'yes', error_message: nil)
        end

        scenario 'the view is rendered with the correct style' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "yes")]/h3[@class="bold"]')
        end
        scenario 'the view is rendered with the correct information' do
          visit application_build_path(application_id: application.id, id: 'benefits_result')
          expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "yes")]/h3[@class="bold"]', text: '✓ The applicant is receiving the correct benefits')
        end
      end
    end
  end
end
