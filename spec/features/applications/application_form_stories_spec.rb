# coding: utf-8
require 'rails_helper'

RSpec.feature 'Completing the application details', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions)      { create_list :jurisdiction, 3 }
  let!(:office)             { create(:office, jurisdictions: jurisdictions) }
  let!(:user)  { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    Capybara.current_driver = :webkit
    Capybara.page.driver.allow_url('http://www.google.com/jsapi')
  end

  after { Capybara.use_default_driver }

  context 'as a signed in user with default jurisdiction', js: true do
    before { login_as user }

    context 'the applicant is single and under 61' do
      context 'after completing the personal details page' do
        before do
          visit applications_new_path

          fill_in 'application_last_name', with: 'Smith'
          fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
          fill_in 'application_ni_number', with: 'AB123456A'
          choose 'application_married_false'
          click_button 'Next'
        end

        scenario 'application details is shown' do
          expect(page).to have_xpath('//h2', text: 'Application details')
        end

        context 'when the dwp says the applicant is not on benefits' do
          before { dwp_api_response 'No' }

          context 'after completing the application_details page' do
            before do
              find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
              fill_in 'application_fee', with: 300
              fill_in 'application_date_received', with: Time.zone.yesterday
              click_button 'Next'
            end

            scenario 'savings and investments is shown' do
              expect(page).to have_xpath('//h2', text: 'Savings and investments')
            end

            context 'when the applicant exceeds the savings threshold' do
              before do
                choose 'application_threshold_exceeded_true'
                click_button 'Next'
              end

              scenario 'the summary page is shown with correct display' do
                expect(page).to have_xpath('//h2', text: 'Check details')
                expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Savings and investments')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Benefits')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Income')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Number of children')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Total monthly income')
                expect(page).to have_xpath('//div[contains(@class,"summary-result success")]', text: '✓ Passed', count: 0)
                expect(page).to have_xpath('//div[contains(@class,"summary-result partial")]', text: '✓ Passed', count: 0)
                expect(page).to have_xpath('//div[contains(@class,"summary-result fail")]', text: '✗ Failed', count: 1)
                expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant must pay the full fee')
              end
            end

            context 'when the applicant passes the savings threshold' do
              before do
                choose 'application_threshold_exceeded_false'
                click_button 'Next'
              end

              scenario 'benefits is shown' do
                expect(page).to have_xpath('//h2', text: 'Benefits')
              end

              context 'when the applicant says they are on benefits' do
                before do
                  choose 'application_benefits_true'
                  click_button 'Next'
                end

                scenario 'benefit results is shown with fail message' do
                  expect(page).to have_xpath('//h2', text: 'Benefits')
                  expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant is not receiving benefits')
                end

                context 'when benefits confirmed' do
                  before { click_button 'Next' }

                  scenario 'the summary page is shown with correct display' do
                    expect(page).to have_xpath('//h2', text: 'Check details')
                    expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Savings and investments')
                    expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Benefits')
                    expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Income')
                    expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Number of children')
                    expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Total monthly income')
                    expect(page).to have_xpath('//div[contains(@class,"summary-result success")]', text: '✓ Passed', count: 1)
                    expect(page).to have_xpath('//div[contains(@class,"summary-result partial")]', text: '✓ Passed', count: 0)
                    expect(page).to have_xpath('//div[contains(@class,"summary-result fail")]', text: '✗ Failed', count: 1)
                    expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant must pay the full fee')
                  end
                end
              end

              context 'when the applicant says they are not on benefits' do
                before do
                  choose 'application_benefits_false'
                  click_button 'Next'
                end

                scenario 'income is shown' do
                  expect(page).to have_xpath('//h2', text: 'Income')
                end

                context 'when the applicant has children' do
                  before do
                    choose 'application_dependents_true'
                  end

                  scenario 'shows children and income inputs' do
                    expect(page).to have_xpath('//input[@id="application_income"]')
                    expect(page).to have_xpath('//input[@id="application_children"]')
                  end

                  context 'after completing income page' do
                    before do
                      fill_in 'application_children', with: 2
                      fill_in 'application_income', with: 1750
                      click_button 'Next'
                    end

                    scenario 'income result is shown with partial message' do
                      expect(page).to have_xpath('//h2', text: 'Income')
                      expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "callout-part")]/h3[@class="bold"]', text: 'The applicant must pay £85 towards the fee')
                    end

                    context 'after confirming income result' do
                      before { click_button 'Next' }

                      scenario 'the summary page is shown with correct display' do
                        expect(page).to have_xpath('//h2', text: 'Check details')
                        expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Savings and investments')
                        expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Benefits')
                        expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Income')
                        expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Number of children')
                        expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Total monthly income')
                        expect(page).to have_xpath('//div[contains(@class,"summary-result success")]', text: '✓ Passed', count: 1)
                        expect(page).to have_xpath('//div[contains(@class,"summary-result partial")]', text: '✓ Passed', count: 1)
                        expect(page).to have_xpath('//div[contains(@class,"summary-result fail")]', text: '✗ Failed', count: 0)
                        expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "callout-part")]/h3[@class="bold"]', text: 'The applicant must pay £85 towards the fee')
                      end

                      context 'when the user returns to the savings threshold' do
                        before { click_link 'Change savings and investments' }

                        scenario 'savings and investments is shown' do
                          expect(page).to have_xpath('//h2', text: 'Savings and investments')
                        end

                        context 'and changes the threshold to exceeded' do
                          before do
                            choose 'application_threshold_exceeded_true'
                            click_button 'Next'
                          end

                          scenario 'the summary page is shown with correct display' do
                            expect(page).to have_xpath('//h2', text: 'Check details')
                            expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Savings and investments')
                            expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Benefits')
                            expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Income')
                            expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Number of children')
                            expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Total monthly income')
                            expect(page).to have_xpath('//div[contains(@class,"summary-result success")]', text: '✓ Passed', count: 0)
                            expect(page).to have_xpath('//div[contains(@class,"summary-result partial")]', text: '✓ Passed', count: 0)
                            expect(page).to have_xpath('//div[contains(@class,"summary-result fail")]', text: '✗ Failed', count: 1)
                            expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant must pay the full fee')
                          end
                        end
                      end
                    end
                  end
                end

                context 'when the applicant does not have children' do
                  before do
                    choose 'application_dependents_false'
                  end

                  scenario 'shows income input' do
                    expect(page).to have_xpath('//input[@id="application_income"]')
                  end
                end
              end
            end
          end
        end

        context 'when the dwp says the applicant is on benefits' do
          before { dwp_api_response 'Yes' }

          context 'after completing the application_details page' do
            before do
              find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
              fill_in 'application_fee', with: 300
              fill_in 'application_date_received', with: Time.zone.yesterday
              click_button 'Next'
            end

            scenario 'savings and investments is shown' do
              expect(page).to have_xpath('//h2', text: 'Savings and investments')
            end

            context 'when the applicant exceeds the savings threshold' do
              before do
                choose 'application_threshold_exceeded_true'
                click_button 'Next'
              end

              scenario 'the summary page is shown with correct display' do
                expect(page).to have_xpath('//h2', text: 'Check details')
                expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Savings and investments')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Benefits')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Income')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Number of children')
                expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Total monthly income')
                expect(page).to have_xpath('//div[contains(@class,"summary-result success")]', text: '✓ Passed', count: 0)
                expect(page).to have_xpath('//div[contains(@class,"summary-result partial")]', text: '✓ Passed', count: 0)
                expect(page).to have_xpath('//div[contains(@class,"summary-result fail")]', text: '✗ Failed', count: 1)
                expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant must pay the full fee')
              end
            end

            context 'when the applicant passes the savings threshold' do
              before do
                choose 'application_threshold_exceeded_false'
                click_button 'Next'
              end

              scenario 'benefits is shown' do
                expect(page).to have_xpath('//h2', text: 'Benefits')
              end

              context 'when the applicant says they are on benefits' do
                before do
                  choose 'application_benefits_true'
                  click_button 'Next'
                end

                scenario 'benefit results is shown with pass message' do
                  expect(page).to have_xpath('//h2', text: 'Benefits')
                  expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "yes")]/h3[@class="bold"]', text: '✓ The applicant is receiving the correct benefits')
                end

                context 'when benefits confirmed' do
                  before { click_button 'Next' }

                  scenario 'the summary page is shown with correct display' do
                    expect(page).to have_xpath('//h2', text: 'Check details')
                    expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Savings and investments')
                    expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Benefits')
                    expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Income')
                    expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Number of children')
                    expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Total monthly income')
                    expect(page).to have_xpath('//div[contains(@class,"summary-result success")]', text: '✓ Passed', count: 2)
                    expect(page).to have_xpath('//div[contains(@class,"summary-result partial")]', text: '✓ Passed', count: 0)
                    expect(page).to have_xpath('//div[contains(@class,"summary-result fail")]', text: '✗ Failed', count: 0)
                    expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "yes")]/h3[@class="bold"]', text: '✓ The applicant doesn’t have to pay the fee')
                  end

                  context 'when the user returns to the savings threshold' do
                    before { click_link 'Change savings and investments' }

                    scenario 'savings and investments is shown' do
                      expect(page).to have_xpath('//h2', text: 'Savings and investments')
                    end

                    context 'and changes the threshold to exceeded' do
                      before do
                        choose 'application_threshold_exceeded_true'
                        click_button 'Next'
                      end

                      scenario 'the summary page is shown with correct display' do
                        expect(page).to have_xpath('//h2', text: 'Check details')
                        expect(page).to have_xpath('//div[contains(@class,"subheader")]', text: 'Savings and investments')
                        expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Benefits')
                        expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Income')
                        expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Number of children')
                        expect(page).to_not have_xpath('//div[contains(@class,"subheader")]', text: 'Total monthly income')
                        expect(page).to have_xpath('//div[contains(@class,"summary-result success")]', text: '✓ Passed', count: 0)
                        expect(page).to have_xpath('//div[contains(@class,"summary-result partial")]', text: '✓ Passed', count: 0)
                        expect(page).to have_xpath('//div[contains(@class,"summary-result fail")]', text: '✗ Failed', count: 1)
                        expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "no")]/h3[@class="bold"]', text: '✗ The applicant must pay the full fee')
                      end
                    end
                  end

                  context 'when the user clicks continue' do
                    before { click_button 'Complete processing' }

                    scenario 'the confirmation is shown' do
                      expect(page).to have_xpath('//h2', text: 'Application processed')
                    end

                    context 'when the user clicks Back to Start' do
                      before { click_link 'Back to start' }

                      scenario 'the home page is shown' do
                        expect(page).to have_text 'Process application'
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
