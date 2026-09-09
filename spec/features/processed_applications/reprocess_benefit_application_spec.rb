require 'rails_helper'

RSpec.feature 'Record benefit evidence received after a benefit application failed' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:user) { create(:user) }
  let(:evidence_question) { 'Has the applicant provided correct evidence to confirm receipt of a qualifying benefit?' }
  let(:today) { Time.zone.today.strftime(Date::DATE_FORMATS[:gov_uk_long]) }

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

    scenario 'the evidence received section is shown and nothing has been reviewed yet' do
      expect(page).to have_text('Evidence Received')
      expect(page).to have_text('Not eligible for help with fees')
      expect(page).to have_css('legend', text: evidence_question, visible: :all)
      expect(page).to have_no_text('Benefits evidence review result')
      expect(page).to have_no_text('Benefits evidence processed')
    end

    scenario 'confirming evidence was received moves the application to a full remission' do
      choose 'benefit_evidence_evidence_true', visible: false
      click_button 'Save and Continue', visible: false

      expect(page).to have_text('Evidence received - the application has been updated to a full remission')
      expect(page).to have_no_text('Evidence Received')
      expect(page).to have_text('Benefits evidence review result')
      expect(page).to have_text('Benefits evidence receivedYes (correct evidence provided)')
      expect(page).to have_text('Eligible for help with fees')
      within '.govuk-table' do
        expect(page).to have_text("Benefits evidence processed#{today}#{user.name}")
      end

      application.reload
      expect(application.decision).to eq('full')
      expect(application.outcome).to eq('none')
      expect(application.decision_cost).to eq(310)
      expect(application.latest_appeal).to have_attributes(correct: true, completed_by: user)
      expect(application.benefit_override.correct).to be false
    end

    scenario 'saying no records the review and keeps the application not eligible' do
      choose 'benefit_evidence_evidence_false', visible: false
      click_button 'Save and Continue', visible: false

      expect(page).to have_text('Evidence not received - the application is not eligible for help with fees')
      expect(page).to have_text('Benefits evidence receivedNo (correct evidence not provided)')
      expect(page).to have_text('Not eligible for help with fees')
      within '.govuk-table' do
        expect(page).to have_text("Benefits evidence processed#{today}#{user.name}")
      end

      expect(page).to have_text('Evidence Received')

      application.reload
      expect(application.decision).to eq('none')
      expect(application.decision_date).to be_nil
      expect(application.latest_appeal).to have_attributes(correct: false, completed_by: user)
    end

    scenario 'a no answer can be followed by a yes answer, which is final' do
      choose 'benefit_evidence_evidence_false', visible: false
      click_button 'Save and Continue', visible: false
      expect(page).to have_text('Not eligible for help with fees')

      choose 'benefit_evidence_evidence_true', visible: false
      click_button 'Save and Continue', visible: false

      expect(page).to have_text('Eligible for help with fees')
      expect(page).to have_no_text('Evidence Received')
      within '.govuk-table' do
        expect(page).to have_css('tr', text: 'Benefits evidence processed', count: 2)
        expect(page).to have_text('Evidence received: "No (correct evidence not provided)"')
        expect(page).to have_text('Evidence received: "Yes (correct evidence provided)"')
      end
      expect(application.reload.decision).to eq('full')
      expect(application.appeals.count).to eq(2)
    end

    scenario 'not answering the question shows an error' do
      click_button 'Save and Continue', visible: false

      expect(page).to have_text('Processed application')
      within '.evidence-received-form' do
        expect(page).to have_text('Select yes or no to confirm whether evidence has been received')
      end
      expect(application.reload.appeals).to be_empty
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
