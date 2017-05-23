require 'rails_helper'

RSpec.feature 'Evidence check', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdiction) { create :jurisdiction }
  let(:office) { create :office, jurisdictions: [jurisdiction] }
  let(:user) { create :user, office: office }

  before do
    login_as user
    dwp_api_response ''
    create_list :application_part_remission, 9
  end

  scenario 'Processing benefit based application' do
    visit  home_index_url

    within "#process-application" do
      expect(page).to have_text('Process application')
      click_button "Start now"
    end

    fill_personal_details
    fill_application_details
    fill_saving_and_investment
    fill_benefits(true)
    fill_benefit_evidence(paper_provided: true, paper_correct: true)

    expect(page).to have_text 'Check details'
    click_button 'Complete processing'
    expect(has_evidence_check?).to be_falsey
  end

  context 'Processing income based application' do
    scenario 'evidence check every 10th application' do
      visit  home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_button "Start now"
      end

      fill_personal_details
      fill_application_details
      fill_saving_and_investment

      fill_benefits(false)
      fill_income(false)

      expect(page).to have_text 'Check details'
      click_button 'Complete processing'
      expect(has_evidence_check?).to be_truthy
    end

    scenario 'evidence check is flaged' do
      visit  home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_button "Start now"
      end

      fill_personal_details('SN123456D')
      fill_application_details
      fill_saving_and_investment

      fill_benefits(false)
      fill_income(false)

      expect(page).to have_text 'Check details'
      click_button 'Complete processing'

      visit home_index_url
      create_flag_check('SN123456D')

      click_button "Start now"
      fill_personal_details('SN123456D')
      fill_application_details
      fill_saving_and_investment

      fill_benefits(true)
      fill_benefit_evidence(paper_provided: true, paper_correct: true)
      click_button 'Complete processing'

      expect(has_evidence_check_flagged?).to be_truthy
    end

    scenario 'no evidence check for 11th application' do
      create :application_part_remission

      visit home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_button "Start now"
      end

      fill_personal_details
      fill_application_details
      fill_saving_and_investment

      fill_benefits(false)
      fill_income(false)

      expect(page).to have_text 'Check details'
      click_button 'Complete processing'
      expect(has_evidence_check?).to be_falsey
    end
  end

  context 'Processing refund based application' do
    before { create(:application, :refund, :income_type, benefits: false, outcome: 'part') }

    scenario 'evidence check ever 2nd application' do
      visit  home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_button "Start now"
      end

      fill_personal_details
      fill_application_refund_details
      fill_saving_and_investment

      fill_benefits(false)
      fill_income(false)

      expect(page).to have_text 'Check details'
      click_button 'Complete processing'
      expect(has_evidence_check?).to be_truthy
    end
  end

  context 'Processing emergency application' do
    scenario 'no evidence check' do
      visit  home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_button "Start now"
      end

      fill_personal_details
      fill_application_emergency_details
      fill_saving_and_investment

      fill_benefits(false)
      fill_income(false)

      expect(page).to have_text 'Check details'
      click_button 'Complete processing'
      expect(has_evidence_check?).to be_falsey
    end
  end

  context 'Processing application with same NI number' do
    scenario 'no evidence check' do
      visit  home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_button "Start now"
      end

      fill_personal_details('SN123456D')
      fill_application_details
      fill_saving_and_investment

      fill_benefits(false)
      fill_income(false)

      expect(page).to have_text 'Check details'
      click_button 'Complete processing'
      expect(has_evidence_check?).to be_truthy

      # Creating another application that should pick up the evidence check
      visit  home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_button "Start now"
      end

      fill_personal_details('SN123456D')
      fill_application_details
      fill_saving_and_investment

      fill_benefits(false)
      fill_income(false)

      expect(page).to have_text 'Check details'
      click_button 'Complete processing'
      expect(has_evidence_check?).to be_truthy
    end
  end
end
