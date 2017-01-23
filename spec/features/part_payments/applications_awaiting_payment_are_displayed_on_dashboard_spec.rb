require 'rails_helper'

RSpec.feature 'Applications awaiting payment are displayed on dashboard', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }
  let(:deleted_user) { create :deleted_user, office: office }

  let(:application1) { create :application_part_remission, :waiting_for_part_payment_state, office: office }
  let(:application2) { create :application_part_remission, :waiting_for_part_payment_state, office: office }
  let(:other_application) { create :application_part_remission, :waiting_for_part_payment_state }
  let(:application4) { create :application_part_remission, :waiting_for_part_payment_state, office: office, user: deleted_user }

  before do
    create :part_payment, application: application1
    create :part_payment, application: application2
    create :part_payment, application: other_application
    create :part_payment, application: application4

    login_as user
  end

  scenario 'User is presented the list of applications awaiting payment only for their office' do
    visit root_path

    within '.waiting-for-part_payment' do
      expect(page).to have_content(application1.reference)
      expect(page).to have_content(application2.reference)
      expect(page).not_to have_content(other_application.reference)
    end
  end

  scenario 'applications by deleted users are shown' do
    visit root_path

    within '.waiting-for-part_payment' do
      expect(page).to have_content(application4.reference)
    end
  end
end
