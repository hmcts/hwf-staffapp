require 'rails_helper'

RSpec.feature 'Applications awaiting evidence are displayed on dashboard', type: :feature do
  enable_evidence_check

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }

  let(:application1) { create :application_full_remission, office: office }
  let!(:evidence1) { create :evidence_check, application: application1 }
  let(:application2) { create :application_full_remission, office: office }
  let!(:evidence2) { create :evidence_check, application: application2 }
  let(:other_application) { create :application_full_remission }
  let!(:other_evidence) { create :evidence_check, application: other_application }
  let(:application3) { create :application_full_remission, office: office }
  let!(:completed_payment) { create :evidence_check, application: application3, completed_at: Time.zone.now }

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

  scenario 'User is presented the list of applications awaiting payment, excluding completed payments' do
    visit root_path

    within '.waiting-for-evidence' do
      expect(page).not_to have_content(application3.reference)
    end
  end
end
