require 'rails_helper'

RSpec.feature 'Evidence check page displays letter to be sent' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  before do
    login_as user
  end

  let(:application) { create(:application_full_remission, office: office) }
  let(:evidence_check) { create(:evidence_check, application: application) }

  scenario 'User navigates to the evidence check page, which has all required details' do
    visit evidence_check_path(evidence_check)

    within '.confirmation-letter' do
      expect(page).to have_text(application.reference)
      expect(page).to have_text(application.applicant.full_name)
      expect(page).to have_text(user.name)
      expect(page).to have_text('28 days')
    end
  end
end
