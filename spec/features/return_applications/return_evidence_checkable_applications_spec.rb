require 'rails_helper'

RSpec.feature 'When evidence checkable applications are returned', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }

  let(:application1) { create :application_full_remission, office: office }
  let!(:evidence1) { create :evidence_check, application: application1 }
  let(:application2) { create :application_full_remission, office: office }
  let!(:evidence2) { create :evidence_check, application: application2 }

  before { login_as user }

  context 'when on home page' do

    before { visit root_path }

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
      expect(page).to have_link 'Return application'
    end

    scenario 'when returning application' do
      click_link application1.reference
      click_link 'Return application'
      expect(page).to have_content 'Processing complete'
      expect(page).to have_link 'Back to start'
    end
  end
end
