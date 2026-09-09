require 'rails_helper'

RSpec.feature 'Reprocess a failed benefit application when evidence is received' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:user) { create(:user) }
  let(:evidence_question) { 'Has the applicant provided correct evidence to confirm receipt of a qualifying benefit?' }

  before do
    login_as(user)
  end

  context 'with a failed benefit application' do
    let(:application) do
      create(:application, :benefit_type, :processed_state, outcome: 'none', office: user.office, fee: '310.00')
    end

    before do
      create(:benefit_override, application: application, correct: false)
      visit processed_application_path(application)
    end

    scenario 'the evidence received section is shown' do
      expect(page).to have_text('Evidence Received')
      expect(page).to have_text('Not eligible for help with fees')
      expect(page).to have_css('legend', text: evidence_question, visible: :all)
      expect(page).to have_no_text('Benefits evidence processed')
    end

    scenario 'confirming evidence was received moves the application to a full remission' do
      choose 'benefit_evidence_evidence_true', visible: false
      click_button 'Save and Continue', visible: false

      expect(page).to have_text('Evidence received - the application has been updated to a full remission')
      expect(page).to have_no_text('Evidence Received')
      expect(page).to have_text('Eligible for help with fees')
      within '.govuk-table' do
        expect(page).to have_text("Benefits evidence processed#{Time.zone.today.strftime(Date::DATE_FORMATS[:gov_uk_long])}#{user.name}")
      end

      application.reload
      expect(application.decision).to eq('full')
      expect(application.decision_cost).to eq(310)
      expect(application.benefit_override).to have_attributes(correct: true, reprocessed: true, completed_by: user)
    end

    scenario 'saying no leaves the application unchanged' do
      choose 'benefit_evidence_evidence_false', visible: false
      click_button 'Save and Continue', visible: false

      expect(page).to have_text('Evidence Received')
      expect(application.reload.decision).to eq('none')
      expect(application.benefit_override.reprocessed).to be false
    end

    scenario 'not answering the question shows an error' do
      click_button 'Save and Continue', visible: false

      expect(page).to have_text('Processed application')
      within '.evidence-received-form' do
        expect(page).to have_text('Select yes or no to confirm whether evidence has been received')
      end
      expect(application.reload.decision).to eq('none')
    end
  end

  context 'with a passed benefit application' do
    let(:application) do
      create(:application, :benefit_type, :processed_state, outcome: 'full', office: user.office)
    end

    scenario 'the evidence received section is not shown' do
      visit processed_application_path(application)

      expect(page).to have_no_text('Evidence Received')
    end
  end

  context 'with a failed income application' do
    let(:application) { create(:application_no_remission, :processed_state, office: user.office) }

    scenario 'the evidence received section is not shown' do
      visit processed_application_path(application)

      expect(page).to have_no_text('Evidence Received')
    end
  end

  context 'as a reader' do
    let(:user) { create(:reader) }
    let(:application) do
      create(:application, :benefit_type, :processed_state, outcome: 'none', office: user.office)
    end

    scenario 'the evidence received section is not shown' do
      visit processed_application_path(application)

      expect(page).to have_no_text('Evidence Received')
    end
  end
end
