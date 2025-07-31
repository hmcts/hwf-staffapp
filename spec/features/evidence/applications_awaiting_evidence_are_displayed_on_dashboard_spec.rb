require 'rails_helper'

RSpec.feature 'Applications awaiting evidence are displayed on dashboard' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:deleted_user) { create(:deleted_user, office: office) }

  let(:application1) { create(:application_full_remission, :waiting_for_evidence_state, office: office) }
  let(:application2) { create(:application_full_remission, :waiting_for_evidence_state, office: office) }
  let(:other_application) { create(:application_full_remission, :waiting_for_evidence_state) }
  let(:application3) { create(:application_full_remission, :waiting_for_evidence_state, office: office, user: deleted_user) }

  before do
    application1
    application2
    other_application
    application3

    login_as user
  end

  scenario 'User is presented the list of applications awaiting evidence only for their office' do
    visit evidence_checks_path

    within '.waiting-for-evidence' do
      expect(page).to have_content(application1.reference)
      expect(page).to have_content(application2.reference)
      expect(page).to have_no_content(other_application.reference)
    end
  end

  scenario 'applications by deleted users are shown' do
    visit evidence_checks_path

    within '.waiting-for-evidence' do
      expect(page).to have_content(application3.reference)
    end
  end
end
