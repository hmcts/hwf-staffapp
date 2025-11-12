require 'rails_helper'

def personal_details_page(ni_number)
  dob = Time.zone.today - 25.years
  fill_in 'application_first_name', with: 'Hirani', wait: true
  fill_in 'application_last_name', with: 'Hirani', wait: true
  fill_in 'application_day_date_of_birth', with: dob.day
  fill_in 'application_month_date_of_birth', with: dob.month
  fill_in 'application_year_date_of_birth', with: dob.year
  fill_in 'application_ni_number', with: ni_number
  choose 'application_married_false'
  click_button 'Next'
end

def application_details
  date_received = Time.zone.today
  fill_in 'application_fee', with: 410, wait: true
  find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
  fill_in 'application_day_date_received', with: date_received.day
  fill_in 'application_month_date_received', with: date_received.month
  fill_in 'application_year_date_received', with: date_received.year
  fill_in 'Form number', with: 'ABC123'
  click_button 'Next'
end

def savings_and_investments
  choose 'application_min_threshold_exceeded_false'
  click_button 'Next'
end

def benefits_page
  choose 'application_benefits_true'
  click_button 'Next'
end

def drive_to_the_benefits_page_undetermined
  personal_details_page(Settings.dwp_mock.ni_number_undetermined.first)
  application_details
  savings_and_investments
  benefits_page
end

def drive_to_the_benefits_page_technical_fault
  personal_details_page(Settings.dwp_mock.ni_number_technical_fault.first)
  application_details
  savings_and_investments
  benefits_page
end

RSpec.feature 'When benefits checker result is valid but not standard response' do
  let!(:jurisdictions)   { create_list(:jurisdiction, 3) }
  let!(:office)          { create(:office, jurisdictions: jurisdictions) }
  let!(:user)            { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  include Warden::Test::Helpers

  Warden.test_mode!

  before do
    login_as user
    start_new_application
  end

  scenario 'let user to override benefits page' do
    drive_to_the_benefits_page_undetermined
    expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
    expect(page).to have_content('This could be due to a system error and/or the applicant not being found from the details provided')
    choose 'benefit_override_evidence_false'
    click_button 'Next'
    expect(page).to have_xpath('//h1', text: 'Check details')
  end

  scenario 'redirect for no evidence from benefits override page' do
    drive_to_the_benefits_page_technical_fault
    expect(page).to have_xpath('//h1', text: 'Evidence of benefits')
    expect(page).to have_content('This could be due to a system error and/or the applicant not being found from the details provided')
    choose 'benefit_override_evidence_false'
    click_button 'Next'
    expect(page).to have_xpath('//h1', text: 'Find an application')
    expect(page).to have_content('Processing benefit applications without paper evidence is not working at the moment. Try again later when the DWP checker is available.')
  end
end
