# coding: utf-8
require 'rails_helper'

RSpec.feature 'The result is shown on the confirmation page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions)      { create_list :jurisdiction, 3 }
  let!(:office)             { create(:office, jurisdictions: jurisdictions) }
  let!(:user)  { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  context 'when the application', js: true do
    before do
      Capybara.current_driver = :webkit
      dwp_api_response 'Yes'

      login_as user

      start_new_application

      fill_in 'application_last_name', with: 'Smith'
      fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
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
        choose 'application_threshold_exceeded_true'
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
        choose 'application_threshold_exceeded_false'
        click_button 'Next'
      end

      context 'is benefit based' do
        before do
          choose 'application_benefits_true'
          click_button 'Next'
          click_link 'Next'
        end

        scenario 'the summary page shows the benefit data' do
          expect(page).to have_xpath('//h2', text: 'Check details')
          expect(page).to have_xpath('//h4', text: 'Savings and investments')
          expect(page).to have_xpath('//h4', text: 'Benefits')
          expect(page).to have_no_xpath('//h4', text: 'Income')

          expect(page).to have_no_xpath('//div[contains(@class,"callout")]')
        end
      end

      context 'is income based' do
        before do
          choose 'application_benefits_false'
          click_button 'Next'
          choose 'application_dependents_true'
          fill_in 'application_children', with: '3'
          fill_in 'application_income', with: '1900'
          click_button 'Next'
          click_link 'Next'
        end

        scenario 'the summary page shows the income data' do
          expect(page).to have_xpath('//h2', text: 'Check details')
          expect(page).to have_xpath('//h4', text: 'Savings and investments')
          expect(page).to have_xpath('//h4', text: 'Benefits')
          expect(page).to have_xpath('//h4', text: 'Income')

          expect(page).to have_no_xpath('//div[contains(@class,"callout")]')
        end
      end
    end
  end
end
