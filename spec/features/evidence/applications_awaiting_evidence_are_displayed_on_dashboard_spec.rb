require 'rails_helper'

RSpec.feature 'Applications awaiting evidence are displayed on dashboard', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }
  let(:deleted_user) { create :deleted_user, office: office }

  let(:application1) { create :application_full_remission, :waiting_for_evidence_state, office: office }
  let!(:evidence_check1) { create :evidence_check, application: application1 }
  let(:application2) { create :application_full_remission, :waiting_for_evidence_state, office: office }
  let!(:evidence_check2) { create :evidence_check, application: application2 }
  let(:other_application) { create :application_full_remission, :waiting_for_evidence_state }
  let!(:other_evidence_check) { create :evidence_check, application: other_application }
  let(:application3) { create :application_full_remission, :waiting_for_evidence_state, office: office, user: deleted_user }
  let!(:evidence_check3) { create :evidence_check, application: application3 }

  before do
    login_as user
  end

  scenario 'User is presented the list of applications awaiting evidence only for their office' do
    visit root_path

    within '.waiting-for-evidence' do
      expect(page).to have_content(application1.reference)
      expect(page).to have_content(application2.reference)
      expect(page).not_to have_content(other_application.reference)
    end
  end

  scenario 'applications by deleted users are shown' do
    visit root_path

    within '.waiting-for-evidence' do
      expect(page).to have_content(application3.reference)
    end
  end
end
