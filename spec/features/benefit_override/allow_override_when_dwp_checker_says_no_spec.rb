# coding: utf-8
require 'rails_helper'

def personal_details_page
  fill_in 'application_last_name', with: 'Smith'
  fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
  fill_in 'application_ni_number', with: 'AB123456A'
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
  choose 'application_min_threshold_exceeded_false'
  click_button 'Next'
end

def benefits_page
  choose 'application_benefits_true'
  click_button 'Next'
end

RSpec.feature 'Allow override when DWP checker says "NO"', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office)        { create(:office, jurisdictions: jurisdictions) }
  let!(:user)          { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    dwp_api_response 'No'
    login_as user
    start_new_application
    personal_details_page
    application_details
    savings_and_investments
    benefits_page
  end

  scenario 'they should be on the Benefit page straight away' do
    expect(page).to have_xpath('//h2', text: 'Benefits')
  end

  context 'when the user provides paper evidence' do
    before do
      choose 'benefit_override_evidence_yes'
    end

    context 'and the evidence is correct' do
      describe 'when displaying the summary' do
        before do
          choose 'benefit_override_correct_true'
          click_button 'Next'
        end

        scenario 'shows the benefits result as passed' do
          expect(page).to have_content 'Check details'
          expect(page).to have_xpath('//div[contains(@class,"column-one-third")][text()="Applicant provided paper evidence"]/following-sibling::*[1][text()="Yes"]')
          expect(page).to have_xpath('//div[contains(@class,"column-one-third")][text()="Benefits letter checked"]/following-sibling::*[1][text()="Yes"]')
        end
      end
    end

    context 'when the user does not provide supporting evidence' do
      describe 'when displaying the summary' do
        before do
          choose 'benefit_override_correct_false'
          fill_in 'benefit_override_incorrect_reason', with: 'some reason'
          click_button 'Next'
        end

        scenario 'shows the benefits result as passed' do
          expect(page).to have_content 'Check details'
          expect(page).to have_xpath('//div[contains(@class,"column-one-third")][text()="Applicant provided paper evidence"]/following-sibling::*[1][text()="Yes"]')
          expect(page).to have_xpath('//div[contains(@class,"column-one-third")][text()="Benefits letter checked"]/following-sibling::*[1][text()="No"]')
        end
      end
    end
  end
end
