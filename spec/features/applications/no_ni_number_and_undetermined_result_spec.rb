require 'rails_helper'

def personal_details_without_ni_number
  login_as user
  visit applications_new_path

  fill_in 'application_last_name', with: 'Smith'
  fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
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

RSpec.feature 'No NI number provided', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office)        { create(:office, jurisdictions: jurisdictions) }
  let!(:user)          { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    personal_details_without_ni_number
    application_details
    savings_and_investments
    benefits_page
  end

  scenario 'correct warning message' do
    warning_string = "The applicant's details could not be checked with the Depatment for Work and Pensions"
    expect(page).to have_content warning_string
  end

  scenario '"Next" button' do
    expect(page).to have_button 'Next'
  end

  context 'when the user progresses to the summary page' do
    before { click_button 'Next' }
    let(:error_message) { 'The applicant must pay the full fee' }

    it { expect(page).to have_content error_message }

    it { expect(page).to have_button 'Complete processing' }

    context 'when the user completes the application' do
      before { click_button 'Complete processing' }

      it { expect(page).to have_content 'Application processed' }

      it { expect(page).to have_content 'The applicant must pay the full fee' }
    end
  end
end
