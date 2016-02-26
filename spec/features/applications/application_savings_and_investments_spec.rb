# coding: utf-8
require 'rails_helper'

RSpec.feature 'Application for savings and investments bug', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
    Capybara.current_driver = :webkit
  end

  after { Capybara.use_default_driver }

  context 'as a signed in user with default jurisdiction', js: true do
    before { login_as user }

    context 'the applicant is single' do
      context 'after completing the personal details page' do
        before do
          start_new_application

          fill_in 'application_last_name', with: 'Hirani'
          fill_in 'application_date_of_birth', with: '28/12/1959'
          fill_in 'application_ni_number', with: 'JL953007D'
          choose 'application_married_false'
          click_button 'Next'
        end

        scenario 'application details is shown' do
          expect(page).to have_xpath('//h2', text: 'Application details')
        end

        context 'when the dwp says the applicant is not on benefits' do
          before { dwp_api_response 'Yes' }

          context 'after completing the application_details page' do
            before do
              fill_in 'application_fee', with: 50
              fill_in 'application_date_received', with: Time.zone.yesterday
              # choose jurisdiction
              find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
              click_button 'Next'
            end

            scenario 'complete savings and investments is shown' do
              expect(page).to have_text 'Savings and investments'
            end

            context 'with the applicant does not exceeds the savings threshold' do
              before do
                choose 'application_threshold_exceeded_true'
                click_button 'Next'
              end

              context 'amend the details for savings and investments' do
                scenario 'edit the savings and investment and benefits pages' do
                  click_link 'Change savings and investments'
                  expect(page).to have_text 'In question 7, the applicant has'
                  choose 'application_threshold_exceeded_false'
                  click_button 'Next'
                  expect(page).to have_text 'Is the applicant receiving one of the benefits listed in question 9?'
                  choose 'application_benefits_true'
                  click_button 'Next'
                  click_button 'Complete processing'

                  expect(page).to have_text 'Eligible for help with fees'
                end
              end
            end
          end
        end
      end
    end

    context 'the applicant is married', js: true do
      before do
        start_new_application

        fill_in 'application_last_name', with: 'Smith'
        fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
        choose 'application_married_true'
        click_button 'Next'
        fill_in 'application_fee', with: '300'
        find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
        fill_in 'application_date_received', with: Time.zone.today - 3.days
        click_button 'Next'
      end

      context 'when the savings investment Next button is clicked' do
        before { click_button 'Next' }

        scenario 'the error message is displayed' do
          expect(page).to have_content 'You must answer the savings question'
        end
      end
    end
  end
end
