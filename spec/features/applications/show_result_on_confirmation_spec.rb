# coding: utf-8

require 'rails_helper'

RSpec.feature 'The result is shown on the confirmation page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  after { Capybara.use_default_driver }

  context 'when the application', js: true do
    before do
      Capybara.current_driver = :webkit
      dwp_api_response 'Yes'

      login_as user

      start_new_application

      fill_in 'application_last_name', with: 'Smith'
      fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
      fill_in 'application_ni_number', with: 'AB123456A'
      choose 'application_married_false'
      click_button 'Next'

      expect(page).to have_xpath('//h2', text: 'Application details')
      fill_in 'application_fee', with: '300'
      find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
      fill_in 'application_date_received', with: Time.zone.today - 3.days
      click_button 'Next'
    end

    context 'exceeds the savings threshold' do
      before do
        choose :application_min_threshold_exceeded_true
        fill_in :application_amount, with: 3500
        click_button 'Next'
      end

      scenario 'the summary page shows the benefit data' do
        expect(page).to have_xpath('//h2', text: 'Check details')
        expect(page).to have_xpath('//h4', text: 'Savings and investments')
        expect(page).to have_no_xpath('//h4', text: 'Income')
        expect(page).to have_no_xpath('//h4', text: 'Benefits')
      end
    end

    context 'does not exceed the savings threshold' do
      before do
        choose 'application_min_threshold_exceeded_false'
        click_button 'Next'
      end

      context 'is benefit based' do
        before do
          choose 'application_benefits_true'
          click_button 'Next'
        end

        scenario 'the summary page shows the benefit data' do
          expect(page).to have_xpath('//h2', text: 'Check details')
          expect(page).to have_xpath('//h4', text: 'Savings and investments')
          expect(page).to have_xpath('//h4', text: 'Benefits')
          expect(page).to have_no_xpath('//h4', text: 'Income')

          expect(page).to have_no_xpath('//div[contains(@class,"callout")]')
        end

        context 'when the "Complete processing" button is pushed' do
          before { click_button 'Complete processing' }

          context 'the confirmation page' do
            scenario 'shows the correct outcomes' do
              expect(page).to have_content 'Savings and investments✓ Passed'
              expect(page).to have_content 'Benefits✓ Passed'
            end

            scenario 'shows the status banner' do
              expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "full")]/h3[@class="heading-large"]', text: 'Eligible for help with fees')
            end
          end
        end
      end

      context 'is income based' do
        before do
          choose 'application_benefits_false'
          click_button 'Next'
          choose 'application_dependents_true'
          fill_in 'application_children', with: '3'
          fill_in 'application_income', with: '1200'
          click_button 'Next'
        end

        scenario 'the summary page shows the income data' do
          expect(page).to have_xpath('//h2', text: 'Check details')
          expect(page).to have_xpath('//h4', text: 'Savings and investments')
          expect(page).to have_xpath('//h4', text: 'Benefits')
          expect(page).to have_xpath('//h4', text: 'Income')

          expect(page).to have_no_xpath('//div[contains(@class,"callout")]')
        end

        context 'when the "Complete processing" button is pushed' do
          before { click_button 'Complete processing' }

          context 'the confirmation page' do
            scenario 'shows the correct outcomes' do
              expect(page).to have_content 'Savings and investments✓ Passed'
              expect(page).to have_content 'Income✓ Passed'
            end

            scenario 'shows the status banner' do
              expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "full")]/h3[@class="heading-large"]', text: 'Eligible for help with fees')
            end
          end
        end
      end
    end
  end
end
