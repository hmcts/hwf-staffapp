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
  choose 'application_threshold_exceeded_false'
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

  scenario 'there should be link for accept the proof for benefit claiming' do
    expect(page).to have_content 'The applicant has provided paper evidence'
  end

  context 'when the user provides paper evidence' do
    before { click_link 'The applicant has provided paper evidence' }

    context 'and the evidence is correct' do
      describe 'when displaying the summary' do
        before do
          choose 'benefit_override_correct_true'
          click_button 'Next'
        end

        scenario 'shows the benefits result as passed' do
          expect(page).to have_content 'Check details'
          expect(page).to have_xpath('//div[contains(@class,"subheader")][text()="Benefit manually overridden?"]/following-sibling::*[1][text()="Yes"]')
          expect(page).to have_xpath('//div[contains(@class,"subheader")][text()="Evidence was correct"]/following-sibling::*[1][text()="Yes"]')
        end
      end
    end

    context 'when the user does not provide supporting evidence' do
      describe 'when displaying the summary' do
        before do
          choose 'benefit_override_correct_false'
          click_button 'Next'
        end

        scenario 'shows the benefits result as passed' do
          expect(page).to have_content 'Check details'
          expect(page).to have_xpath('//div[contains(@class,"subheader")][text()="Benefit manually overridden?"]/following-sibling::*[1][text()="Yes"]')
          expect(page).to have_xpath('//div[contains(@class,"subheader")][text()="Evidence was correct"]/following-sibling::*[1][text()="No"]')
        end
      end
    end
  end
end
