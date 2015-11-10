# coding: utf-8
require 'rails_helper'

def personal_details_without_ni_number
  login_as user
  start_new_application

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
  let(:paper_evidence) { 'The applicant has provided paper evidence' }
  let(:no_remission)   { 'The applicant must pay the full fee' }

  before do
    personal_details_without_ni_number
    application_details
    savings_and_investments
    benefits_page
  end

  scenario 'correct content on the page' do
    warning_string = "The applicant's details could not be checked with the Department for Work and Pensions"
    expect(page).to have_content warning_string
    expect(page).to have_link 'Next'
    expect(page).to have_text paper_evidence
  end

  context 'when the user tries to process paper evidence' do
    before { click_link paper_evidence }

    context 'when the evidence is valid' do
      let(:full_remission) { "The applicant doesn’t have to pay the fee" }

      before do
        choose 'benefit_override_correct_true'
        click_button 'Next'
      end

      scenario 'has the correct title and message' do
        expect(page).to have_content 'Check details'
        expect(page).to have_content full_remission
      end

      context 'when the user progresses to the confirmation page' do
        before { click_link 'Complete processing' }

        scenario 'shows the full remission message' do
          expect(page).to have_content full_remission
        end
      end
    end

    context 'when the evidence is invalid' do
      before do
        choose 'benefit_override_correct_false'
        click_button 'Next'
      end

      scenario 'takes them the confirmation page' do
        expect(page).to have_content 'Check details'
      end

      it { expect(page).to have_content no_remission }
    end
  end

  context 'when the user progresses to the summary page' do
    before { click_link 'Next' }

    it do
      expect(page).to have_content no_remission
      expect(page).to have_content 'Check details'
    end

    context 'when the user completes the application' do
      before { click_link 'Complete processing' }

      it do
        expect(page).to have_content 'Application processed'
        expect(page).to have_content no_remission
      end
    end
  end
end
