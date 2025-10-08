require 'rails_helper'

# PRE UCD
RSpec.feature 'When evidence checkable applications are returned' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  let(:application1) { create(:application_full_remission, :waiting_for_evidence_state, office: office) }
  let(:application2) { create(:application_full_remission, :waiting_for_evidence_state, office: office) }
  before do
    application1
    application2
    login_as user
  end

  context 'when on home page' do

    before { visit evidence_checks_path }

    scenario 'shows the applications that should be checked for evidence' do
      within '.waiting-for-evidence' do
        expect(page).to have_content(application1.reference)
        expect(page).to have_content(application2.reference)
      end
    end

    scenario 'shows "Return application" button' do
      click_link application1.reference
      expect(page).to have_content 'Process evidence'
      expect(page).to have_content application1.applicant.full_name
      expect(page).to have_content "What to do if evidence hasn't arrived"
      expect(page).to have_link 'Return application', visible: :hidden
    end

    scenario 'when returning application' do
      click_link application1.reference
      click_link 'Return application', visible: false

      expect(page).to have_content 'What is the problem?'
      choose 'Citizen not proceeding'
      click_button 'Next'
      expect(page).to have_content 'Processing complete'
      expect(application1.reload.state).to eq 'processed'

      click_link 'Back to start'
      expect(page).to have_button 'Start now'
      expect(page).to have_no_content application1.reference
    end
  end
end
