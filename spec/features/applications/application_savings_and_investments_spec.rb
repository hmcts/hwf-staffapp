# coding: utf-8
require 'rails_helper'

RSpec.feature 'Application for savings and investments bug', type: :feature do

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

  context 'as a signed in user with default jurisdiction', js: true do
    before { login_as user }

    context 'the applicant is single' do
      context 'after completing the personal details page' do
        before do
          visit applications_new_path

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
          before do
            json = '{"original_client_ref": "unique", "benefit_checker_status": "Yes",
             "confirmation_ref": "T1426267181940",
             "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
            stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
              to_return(status: 200, body: json, headers: {})
          end

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

              scenario 'the summary page is shown with the error' do
                expect(page).to have_text '✗ The applicant must pay the full fee'
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
                  click_button 'Next'
                  expect(page).to have_text '✓ The applicant doesn’t have to pay the fee'
                end
              end
            end
          end
        end
      end
    end
  end
end
