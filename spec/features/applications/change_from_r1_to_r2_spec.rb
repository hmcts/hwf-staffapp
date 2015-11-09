# coding: utf-8
require 'rails_helper'

RSpec.feature 'Completing the application details', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions)      { create_list :jurisdiction, 3 }
  let!(:office)             { create(:office, jurisdictions: jurisdictions) }
  let!(:user)  { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
    Capybara.current_driver = :webkit
    Capybara.page.driver.allow_url('http://www.google.com/jsapi')
  end

  after { Capybara.use_default_driver }

  context 'complete r2 path as a signed in user with default jurisdiction', js: true do
    before do
      dwp_api_response 'Yes'

      login_as user
      visit applications_new_path
      fill_in 'application_last_name', with: 'Hirani'
      fill_in 'application_date_of_birth', with: '28/12/1959'
      fill_in 'application_ni_number', with: 'JL953007D'
      choose 'application_married_false'
      click_button 'Next'
      find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
      fill_in 'application_fee', with: 410
      fill_in 'application_date_received', with: Time.zone.yesterday
      click_button 'Next'
      choose 'application_threshold_exceeded_false'
      click_button 'Next'
      choose 'application_benefits_false'
      click_button 'Next'
      choose 'application_dependents_true'
      fill_in 'application_children', with: '3'
      fill_in 'application_income', with: '1900'
      click_button 'Next'
      click_link 'Next'
    end

    scenario 'shows the proper summary page' do
      expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "callout-part")]/h3[@class="bold"]', text: 'The applicant must pay £40 towards the fee')
    end

    context 'return and set to R1' do
      before do
        click_link 'Change personal information'
        click_button 'Next'
        click_button 'Next'
        click_button 'Next'
        choose 'application_benefits_true'
        click_button 'Next'
        click_link 'Next'
      end

      scenario 'shows benefit result on summary page' do
        expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "full")]/h3[@class="bold"]', text: '✓ The applicant doesn’t have to pay the fee')
      end
    end
  end
end
