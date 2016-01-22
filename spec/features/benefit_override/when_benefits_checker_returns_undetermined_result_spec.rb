require 'rails_helper'

def personal_details_page
  fill_in 'application_last_name', with: 'Hirani'
  fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
  fill_in 'application_ni_number', with: 'JK089012B'
  choose 'application_married_false'
  click_button 'Next'
end

def application_details
  fill_in 'application_fee', with: 410
  find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
  fill_in 'application_date_received', with: Time.zone.today
  click_button 'Next'
end

def savings_and_investments
  choose 'application_threshold_exceeded_false'
  click_button 'Next'
end

def benefits_page
  choose 'application_benefits_true'
  click_button 'Next'
end

def drive_to_the_benefits_page
  personal_details_page
  application_details
  savings_and_investments
  benefits_page
end

RSpec.feature 'When benefits checker result is "Undetermined"', type: :feature do
  let!(:jurisdictions)   { create_list :jurisdiction, 3 }
  let!(:office)          { create(:office, jurisdictions: jurisdictions) }
  let!(:user)            { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  include Warden::Test::Helpers
  Warden.test_mode!

  before do
    dwp_api_response 'Undetermined'

    login_as user
    start_new_application

    drive_to_the_benefits_page
  end

  xscenario 'shows the benefits override page' do
    expect(page).to have_xpath('//h2', text: 'Benefits')
    warning_message = 'The applicant’s details could not be checked with the Department for Work and Pensions'
    expect(page).to have_content warning_message
  end
end
