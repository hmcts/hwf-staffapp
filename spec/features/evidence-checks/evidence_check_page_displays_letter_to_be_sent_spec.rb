require 'rails_helper'

RSpec.feature 'Evidence check page displays letter to be sent', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  let(:application) { create :application_full_remission }
  let(:evidence_check) { create :evidence_check, application: application }

  context 'when the evidence_check feature is enabled' do
    enable_evidence_check

    scenario 'User navigates to the evidence check page, which has all required details' do
      visit evidence_check_path(evidence_check)

      within '.evidence-check-letter' do
        expect(page).to have_content(application.reference)
        expect(page).to have_content(application.full_name)
        expect(page).to have_content(user.name)
        expect(page).to have_content(evidence_check.expires_at.to_date)
      end
    end
  end

  context 'when the evidence_check feature is disabled' do
    disable_evidence_check

    scenario 'User can not navigate to the evidence check page' do
      visit evidence_check_path(evidence_check)

      expect(page.status_code).to be 404
    end
  end
end
